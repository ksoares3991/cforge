#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_FILE="$PROJECT_DIR/cbuild.conf"
if [ -f "$CONFIG_FILE" ]; then
	source "$CONFIG_FILE"
fi

EXEC_NAME="${EXEC_NAME:-programa}"

log() {
	local comando="$1"
	local duracao="$2"
	local codigo="$3"
	local mensagem="$4"
	local diretorio="${SOURCE_DIR:-$(pwd)}"

	if ! mkdir -p "$diretorio/logs" 2> /dev/null; then
		echo "AVISO: não foi possível criar $diretorio/logs; a operação não está sendo registrada" >&2
		return 1
	fi

	mensagem=$(printf '%s' "$mensagem" | tr '\n|' '  ')

	echo "$(date '+%Y-%m-%d|%H:%M:%S')|$comando|$duracao|$codigo|$mensagem" \
		>> "$diretorio/logs/cbuild.log"
}
