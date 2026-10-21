#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
log_debug "PROJECT_DIR=$PROJECT_DIR"

SECONDS=0
OPT_LEVEL=0
FORCE_REBUILD=0
SOURCE_DIR=""

for arg in "$@"; do
    case "$arg" in
        --opt=0|--opt=1|--opt=2) OPT_LEVEL="${arg#--opt=}" ;;
        --opt=*)
            echo "error: invalid optimization level: '${arg#--opt=}' (use 0, 1, or 2)" >&2
            exit 1
            ;;
        --no-incremental) FORCE_REBUILD=1 ;;
        --verbose) VERBOSE=1 ;;
        --debug) DEBUG=1 ;;
        --) ;;
        --*) echo "error: invalid option: $arg" >&2; exit 1 ;;
        *) [ -z "$SOURCE_DIR" ] && SOURCE_DIR="$arg" ;;
    esac
done

SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"
log_debug "SOURCE_DIR=$SOURCE_DIR"
log_debug "OPT_LEVEL=$OPT_LEVEL FORCE_REBUILD=$FORCE_REBUILD EXEC_NAME=$EXEC_NAME"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "project directory not found: $SOURCE_DIR" >&2
    exit 1
fi

if ! command -v gcc > /dev/null 2>&1; then
    message="GCC not found. Aborting."
    echo "$message" >&2
    log "build" "$SECONDS" 1 "$message"
    exit 1
fi

mapfile -t SOURCES < <(find "$SOURCE_DIR" \
    \( -path "$SOURCE_DIR/build" -o -path "$SOURCE_DIR/logs" \) -prune -o \
    -type f -name "*.c" -print)

log_verbose "found ${#SOURCES[@]} .c files"

if [ ${#SOURCES[@]} -eq 0 ]; then
    message="no .c files found. Aborting."
    echo "$message" >&2
    log "build" "$SECONDS" 1 "$message"
    exit 1
fi

if ! mkdir -p "$SOURCE_DIR/build/" 2> /dev/null; then
    message="could not create $SOURCE_DIR/build/. Aborting."
    echo "$message" >&2
    log "build" "$SECONDS" 1 "$message"
    exit 1
fi

echo "compiling with optimization level -O${OPT_LEVEL}"
log_verbose "project directory: $SOURCE_DIR"
log_verbose "executable: $SOURCE_DIR/build/$EXEC_NAME"

NEEDS_BUILD=0
if [ "$FORCE_REBUILD" -eq 1 ] || [ ! -f "$SOURCE_DIR/build/$EXEC_NAME" ]; then
    NEEDS_BUILD=1
else
    for src in "${SOURCES[@]}"; do
        if [ "$src" -nt "$SOURCE_DIR/build/$EXEC_NAME" ]; then
            NEEDS_BUILD=1
            break
        fi
    done
fi

if [ "$NEEDS_BUILD" -eq 0 ]; then
    echo "nothing to recompile — executable is up to date."
    log "build" "$SECONDS" 0 ""
    exit 0
fi

log_verbose "running: gcc -O${OPT_LEVEL} -I $SOURCE_DIR/include ${SOURCES[*]} -o $SOURCE_DIR/build/$EXEC_NAME"

errors=$(mktemp)
gcc -O"${OPT_LEVEL}" -I "$SOURCE_DIR/include" "${SOURCES[@]}" -o "$SOURCE_DIR/build/$EXEC_NAME" 2> "$errors"
code=$?
duration=$SECONDS

cat "$errors" >&2

if [ "$code" -ne 0 ]; then
    log "build" "$duration" "$code" "$(cat "$errors")"
    rm -f "$errors"
    echo "compilation error. Aborting." >&2
    exit "$code"
fi

rm -f "$errors"
log "build" "$duration" 0 ""
echo "build successful!"
exit 0
