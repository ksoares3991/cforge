#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SECONDS=0
SOURCE_DIR=""

for arg in "$@"; do
    case "$arg" in
        --verbose) VERBOSE=1 ;;
        --debug) DEBUG=1 ;;
        --*) echo "error: invalid option: $arg" >&2; exit 1 ;;
        *) [ -z "$SOURCE_DIR" ] && SOURCE_DIR="$arg" ;;
    esac
done

SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"

EXEC_FILE="$SOURCE_DIR/build/$EXEC_NAME"

if [ ! -f "$EXEC_FILE" ] || [ ! -x "$EXEC_FILE" ]; then
	message="error: executable not found; run ./cbuild build"
	echo "$message" >&2
	log "run" "$SECONDS" 1 "$message"
	exit 1
fi

"$EXEC_FILE"
code=$?
duration=$SECONDS

date '+%Y-%m-%d %H:%M:%S' > "$SOURCE_DIR/build/.last_run" 2>/dev/null

if [ "$code" -eq 0 ]; then
	log "run" "$duration" "$code" ""
else
	log "run" "$duration" "$code" "program exited with code $code"
fi

exit "$code"
