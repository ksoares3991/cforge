#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")"

SECONDS=0
SOURCE_DIR=""

for arg in "$@"; do
    case "$arg" in
        --opt=0|--opt=1|--opt=2) ;;
        --no-incremental) ;;
        --verbose) VERBOSE=1 ;;
        --debug) DEBUG=1 ;;
        --*) echo "erro: opção inválida: $arg" >&2; exit 1 ;;
        *) [ -z "$SOURCE_DIR" ] && SOURCE_DIR="$arg" ;;
    esac
done

SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"

comuns=()
for arg in "$@"; do
    case "$arg" in
        --verbose|--debug) comuns+=("$arg") ;;
    esac
done
"$SCRIPTS_DIR/clean.sh" "${comuns[@]}"
codigo=$?

if [ "$codigo" -ne 0 ]; then
	mensagem="Limpeza falhou; compilação não executada."
	echo "$mensagem" >&2
	log "rebuild" "$SECONDS" "$codigo" "$mensagem"
	exit "$codigo"
fi

"$SCRIPTS_DIR/build.sh" "$@"
codigo=$?
duracao=$SECONDS

if [ "$codigo" -eq 0 ]; then
	log "rebuild" "$duracao" 0 ""
else
	log "rebuild" "$duracao" "$codigo" "Compilação falhou durante o rebuild."
fi

exit "$codigo"
