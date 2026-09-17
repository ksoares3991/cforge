#!/bin/bash

comando="$1"
shift

case "$comando" in
  build)   scripts/build.sh "$@" ;;
  run)     scripts/run.sh "$@" ;;
  clean)   scripts/clean.sh "$@" ;;
  rebuild) scripts/rebuild.sh "$@" ;;
  info)    scripts/info.sh "$@" ;;
  *)       echo "comando inválido: $comando" >&2; exit 1 ;;
esac
