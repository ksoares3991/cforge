#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

argumento="$1"
SOURCE_DIR="${argumento:-$(pwd)}"

if [ ! -x "$SOURCE_DIR/build/$EXEC_NAME" ]; then
	echo 'erro: executável não encontrado; execute ./cbuild build' >&2
	exit 1
fi

"$SOURCE_DIR/build/$EXEC_NAME"
