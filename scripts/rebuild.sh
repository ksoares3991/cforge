#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")"

SECONDS=0
SOURCE_DIR=""

for arg in "$@"; do
    case "$arg" in
        --opt=0|--opt=1|--opt=2) ;;
        --no-incremental) ;;
        --verbose) VERBOSE=1 ;;
        --debug) DEBUG=1 ;;
        --*) echo "error: invalid option: $arg" >&2; exit 1 ;;
        *) [ -z "$SOURCE_DIR" ] && SOURCE_DIR="$arg" ;;
    esac
done

SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"

common_flags=()
for arg in "$@"; do
    case "$arg" in
        --verbose|--debug) common_flags+=("$arg") ;;
    esac
done
"$SCRIPTS_DIR/clean.sh" "$SOURCE_DIR" "${common_flags[@]}"
code=$?

if [ "$code" -ne 0 ]; then
	message="clean step failed; build not executed."
	echo "$message" >&2
	log "rebuild" "$SECONDS" "$code" "$message"
	exit "$code"
fi

"$SCRIPTS_DIR/build.sh" "$@"
code=$?
duration=$SECONDS

if [ "$code" -eq 0 ]; then
	log "rebuild" "$duration" 0 ""
else
	log "rebuild" "$duration" "$code" "build step failed during rebuild."
fi

exit "$code"
