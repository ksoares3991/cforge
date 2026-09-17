#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_FILE="$PROJECT_DIR/cbuild.conf"
if [ -f "$CONFIG_FILE" ]; then
	source "$CONFIG_FILE"
fi

EXEC_NAME="${EXEC_NAME:-programa}"
