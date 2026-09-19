#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_FILE="$PROJECT_DIR/cbuild.conf"
if [ -f "$CONFIG_FILE" ]; then
	source "$CONFIG_FILE"
fi

EXEC_NAME="${EXEC_NAME:-programa}"
VERBOSE=0
DEBUG=0

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

log_verbose() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo "[verbose] $*"
    fi
}

log_debug() {
    if [ "$DEBUG" -eq 1 ]; then
        echo "[debug] $*" >&2
    fi
}
