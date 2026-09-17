#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

comando="$1"
if [ -z "$comando" ]; then
  echo "comandos disponíveis: build, run, clean, rebuild, info"
  exit 1
fi

shift

case "$comando" in
  build)   scripts/build.sh "$@" ;;
  run)     scripts/run.sh "$@" ;;
  clean)   scripts/clean.sh "$@" ;;
  rebuild) scripts/rebuild.sh "$@" ;;
  info)    scripts/info.sh "$@" ;;
  *)       echo "comando inválido: $comando" >&2; exit 1 ;;
esac
