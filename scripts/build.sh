#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

argumento="$1"
SOURCE_DIR="${argumento:-$(pwd)}"

if ! command -v gcc > /dev/null 2>&1; then
	echo "GCC não instalado. Fim do programa."
	exit 1
fi

mapfile -t SOURCES < <(find "$SOURCE_DIR" -name "*.c")

if [ ${#SOURCES[@]} -eq 0 ]; then
	echo "Arquivos .c não encontrados. Fim do programa!"
	exit 1
fi
