#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
log_debug "PROJECT_DIR=$PROJECT_DIR"

SECONDS=0
OPT_LEVEL=0
FORCE_REBUILD=0
SOURCE_DIR=""

for arg in "$@"; do
    case "$arg" in
        --opt=0|--opt=1|--opt=2) OPT_LEVEL="${arg#--opt=}" ;;
        --opt=*)
            echo "erro: nível de otimização inválido: '${arg#--opt=}' (use 0, 1 ou 2)" >&2
            exit 1
            ;;
        --no-incremental) FORCE_REBUILD=1 ;;
        --verbose) VERBOSE=1 ;;
        --debug) DEBUG=1 ;;
        --) ;;
        --*) echo "erro: opção inválida: $arg" >&2; exit 1 ;;
        *) [ -z "$SOURCE_DIR" ] && SOURCE_DIR="$arg" ;;
    esac
done

SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"
log_debug "SOURCE_DIR=$SOURCE_DIR"
log_debug "OPT_LEVEL=$OPT_LEVEL FORCE_REBUILD=$FORCE_REBUILD EXEC_NAME=$EXEC_NAME"

log_debug "SOURCE_DIR=$SOURCE_DIR"
log_debug "OPT_LEVEL=$OPT_LEVEL FORCE_REBUILD=$FORCE_REBUILD EXEC_NAME=$EXEC_NAME"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Diretório do projeto não encontrado: $SOURCE_DIR" >&2
    exit 1
fi

if ! command -v gcc > /dev/null 2>&1; then
    mensagem="GCC não instalado. Fim do programa!"
    echo "$mensagem" >&2
    log "build" "$SECONDS" 1 "$mensagem"
    exit 1
fi

mapfile -t SOURCES < <(find "$SOURCE_DIR" \
    \( -path "$SOURCE_DIR/build" -o -path "$SOURCE_DIR/logs" \) -prune -o \
    -type f -name "*.c" -print)

log_verbose "arquivos .c encontrados: ${#SOURCES[@]}"

log_verbose "arquivos .c encontrados: ${#SOURCES[@]}"

if [ ${#SOURCES[@]} -eq 0 ]; then
    mensagem="Arquivos .c não encontrados. Fim do programa!"
    echo "$mensagem" >&2
    log "build" "$SECONDS" 1 "$mensagem"
    exit 1
fi

if ! mkdir -p "$SOURCE_DIR/build/" 2> /dev/null; then
    mensagem="Não foi possível criar $SOURCE_DIR/build/. Fim do programa!"
    echo "$mensagem" >&2
    log "build" "$SECONDS" 1 "$mensagem"
    exit 1
fi

echo "compilando com nível de otimização -O${OPT_LEVEL}"
log_verbose "diretório do projeto: $SOURCE_DIR"
log_verbose "executável: $SOURCE_DIR/build/$EXEC_NAME"

log_verbose "diretório do projeto: $SOURCE_DIR"
log_verbose "executável: $SOURCE_DIR/build/$EXEC_NAME"

NEEDS_BUILD=0
if [ "$FORCE_REBUILD" -eq 1 ] || [ ! -f "$SOURCE_DIR/build/$EXEC_NAME" ]; then
    NEEDS_BUILD=1
else
    for src in "${SOURCES[@]}"; do
        if [ "$src" -nt "$SOURCE_DIR/build/$EXEC_NAME" ]; then
            NEEDS_BUILD=1
            break
        fi
    done
fi

if [ "$NEEDS_BUILD" -eq 0 ]; then
    echo "nada a recompilar — executável está atualizado."
    log "build" "$SECONDS" 0 ""
    exit 0
fi

log_verbose "executando: gcc -O${OPT_LEVEL} -I $SOURCE_DIR/include ${SOURCES[*]} -o $SOURCE_DIR/build/$EXEC_NAME"

erros=$(mktemp)
gcc -O"${OPT_LEVEL}" -I "$SOURCE_DIR/include" "${SOURCES[@]}" -o "$SOURCE_DIR/build/$EXEC_NAME" 2> "$erros"
codigo=$?
duracao=$SECONDS

cat "$erros" >&2

if [ "$codigo" -ne 0 ]; then
    log "build" "$duracao" "$codigo" "$(cat "$erros")"
    rm -f "$erros"
    echo "Erro de compilação. Fim do programa!" >&2
    exit "$codigo"
fi

rm -f "$erros"
log "build" "$duracao" 0 ""
echo "Compilação feita com sucesso!"
exit 0
