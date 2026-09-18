#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SECONDS=0

argumento="$1"
SOURCE_DIR="${argumento:-$(pwd)}"

if [ ! -d "$SOURCE_DIR" ]; then
	echo "Diretório do projeto não encontrado: $SOURCE_DIR" >&2
	exit 1
fi

if [ ! -d "$SOURCE_DIR/build" ]; then
	echo "Nada a limpar: $SOURCE_DIR/build/ não existe."
	log "clean" "$SECONDS" 0 ""
	exit 0
fi

if ! rm -rf "$SOURCE_DIR/build" 2> /dev/null; then
	mensagem="Não foi possível remover $SOURCE_DIR/build/. Fim do programa!"
	echo "$mensagem" >&2
	log "clean" "$SECONDS" 1 "$mensagem"
	exit 1
fi

log "clean" "$SECONDS" 0 ""
echo "Limpeza feita com sucesso!"
exit 0
