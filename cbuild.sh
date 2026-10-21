#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

cmd="$1"
if [ -z "$cmd" ]; then
  echo "available commands: build, run, clean, rebuild, info"
  exit 1
fi

shift

case "$cmd" in
  build)   "$PROJECT_DIR/scripts/build.sh" "$@" ;;
  run)     "$PROJECT_DIR/scripts/run.sh" "$@" ;;
  clean)   "$PROJECT_DIR/scripts/clean.sh" "$@" ;;
  rebuild) "$PROJECT_DIR/scripts/rebuild.sh" "$@" ;;
  info)    "$PROJECT_DIR/scripts/info.sh" "$@" ;;
  *)       echo "invalid command: $cmd" >&2; exit 1 ;;
esac
