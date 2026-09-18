#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")"

SECONDS=0

argumento="$1"
SOURCE_DIR="${argumento:-$(pwd)}"

"$SCRIPTS_DIR/clean.sh" "$@"
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
