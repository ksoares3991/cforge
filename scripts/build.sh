#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

argumento="$1"
SOURCE_DIR="${argumento:-$(pwd)}"

mapfile -t SOURCES < <(find "$SOURCE_DIR" -name "*.c")

if [ ${#SOURCES[@]} -eq 0 ]; then
	echo "Arquivos .c não encontrados. Fim do programa!"
	exit 1
fi
