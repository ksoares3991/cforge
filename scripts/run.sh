#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SECONDS=0
SOURCE_DIR=""

for arg in "$@"; do
    case "$arg" in
        --verbose) VERBOSE=1 ;;
        --debug) DEBUG=1 ;;
        --*) echo "erro: opção inválida: $arg" >&2; exit 1 ;;
        *) [ -z "$SOURCE_DIR" ] && SOURCE_DIR="$arg" ;;
    esac
done

SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"

EXEC_FILE="$SOURCE_DIR/build/$EXEC_NAME"

if [ ! -f "$EXEC_FILE" ] || [ ! -x "$EXEC_FILE" ]; then
	mensagem="ERRO: executável não encontrado; execute ./cbuild build"
	echo "$mensagem" >&2
	log "run" "$SECONDS" 1 "$mensagem"
	exit 1
fi

"$EXEC_FILE"
codigo=$?
duracao=$SECONDS

date '+%Y-%m-%d %H:%M:%S' > "$SOURCE_DIR/build/.last_run" 2>/dev/null

if [ "$codigo" -eq 0 ]; then
	log "run" "$duracao" "$codigo" ""
else
	log "run" "$duracao" "$codigo" "o programa terminou com código $codigo"
fi

exit "$codigo"
