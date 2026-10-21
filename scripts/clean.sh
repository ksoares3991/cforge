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

if [ ! -d "$SOURCE_DIR" ]; then
	echo "project directory not found: $SOURCE_DIR" >&2
	exit 1
fi

if [ ! -d "$SOURCE_DIR/build" ]; then
	echo "nothing to clean: $SOURCE_DIR/build/ does not exist."
	log "clean" "$SECONDS" 0 ""
	exit 0
fi

if ! rm -rf "$SOURCE_DIR/build" 2> /dev/null; then
	message="could not remove $SOURCE_DIR/build/. Aborting."
	echo "$message" >&2
	log "clean" "$SECONDS" 1 "$message"
	exit 1
fi

log "clean" "$SECONDS" 0 ""
echo "clean successful!"
exit 0
