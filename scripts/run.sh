#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SECONDS=0

argumento="$1"
SOURCE_DIR="${argumento:-$(pwd)}"

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

if [ "$codigo" -eq 0 ]; then
	log "run" "$duracao" "$codigo" ""
else
	log "run" "$duracao" "$codigo" "o programa terminou com código $codigo"
fi

exit "$codigo"
