#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_FILE="$PROJECT_DIR/cbuild.conf"
if [ -f "$CONFIG_FILE" ]; then
	source "$CONFIG_FILE"
fi

EXEC_NAME="${EXEC_NAME:-program}"
VERBOSE=0
DEBUG=0

log() {
	local cmd="$1"
	local duration="$2"
	local code="$3"
	local message="$4"
	local dir="${SOURCE_DIR:-$(pwd)}"

	if ! mkdir -p "$dir/logs" 2> /dev/null; then
		echo "WARNING: could not create $dir/logs; operation will not be logged" >&2
		return 1
	fi

	message=$(printf '%s' "$message" | tr '\n|' '  ')

	echo "$(date '+%Y-%m-%d|%H:%M:%S')|$cmd|$duration|$code|$message" \
		>> "$dir/logs/cbuild.log"
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
