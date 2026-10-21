#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SECONDS=0
SOURCE_DIR=""
GENERATE_REPORT=0

for arg in "$@"; do
    case "$arg" in
        --report) GENERATE_REPORT=1 ;;
        --verbose) VERBOSE=1 ;;
        --debug) DEBUG=1 ;;
        --*) echo "error: invalid option: $arg" >&2; exit 1 ;;
        *) [ -z "$SOURCE_DIR" ] && SOURCE_DIR="$arg" ;;
    esac
done

SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"
SOURCE_DIR="${SOURCE_DIR%/}"

UNAVAILABLE="unavailable"
LOG_FILE="$SOURCE_DIR/logs/cbuild.log"
EXEC_FILE="$SOURCE_DIR/build/$EXEC_NAME"

die() {
	local message="$1"
	local code="$2"
	echo "$message" >&2
	log "info" "$SECONDS" "$code" "$message"
	exit "$code"
}

list_sources() {
	local ext="$1"
	find "$SOURCE_DIR" \
		\( -path "$SOURCE_DIR/build" -o -path "$SOURCE_DIR/logs" \) -prune -o \
		-type f -name "*.$ext" -print
}

count_loc() {
    local total=0 f n
    for f in "$@"; do
        n=$(grep -cve '^[[:space:]]*$' "$f" 2>/dev/null)
        n=${n:-0}
        total=$((total + n))
    done
    echo "$total"
}

last_operation_date() {
	local target="$1"
	local date_field time_field cmd_field dur_field code_field msg_field
	local result="$UNAVAILABLE"

	if [ ! -r "$LOG_FILE" ]; then
		echo "$result"
		return
	fi

	while IFS='|' read -r date_field time_field cmd_field dur_field code_field msg_field; do
		if [ "$cmd_field" = "$target" ] && [ "$code_field" = "0" ]; then
			result="$date_field $time_field"
		fi
	done < "$LOG_FILE"

	echo "$result"
}

if [ ! -d "$SOURCE_DIR" ]; then
	echo "error: project directory not found: $SOURCE_DIR" >&2
	exit 1
fi

if [ ! -r "$SOURCE_DIR" ] || [ ! -x "$SOURCE_DIR" ]; then
	die "error: insufficient permissions to read directory $SOURCE_DIR" 1
fi

c_files=()
while IFS= read -r file; do
	c_files+=("$file")
done < <(list_sources c)

h_files=()
while IFS= read -r file; do
	h_files+=("$file")
done < <(list_sources h)

total_files=$(( ${#c_files[@]} + ${#h_files[@]} ))
total_loc=$(count_loc "${c_files[@]}" "${h_files[@]}")

if [ -f "$EXEC_FILE" ]; then
	if [ -r "$EXEC_FILE" ]; then
		exec_size="$(wc -c < "$EXEC_FILE") bytes"
	else
		die "error: insufficient permissions to read executable $EXEC_FILE" 1
	fi
else
	exec_size="$UNAVAILABLE"
fi

last_build=$(last_operation_date "build")
last_run=$(last_operation_date "run")

echo "Project: $SOURCE_DIR"
echo ".c files: ${#c_files[@]}"
echo ".h files: ${#h_files[@]}"
echo "Total source files: $total_files"
echo "Lines of code: $total_loc"
echo "Executable: $EXEC_FILE"
echo "Executable size: $exec_size"
echo "Last build: $last_build"
echo "Last run: $last_run"

if [ "$GENERATE_REPORT" -eq 1 ]; then
    mkdir -p "$SOURCE_DIR/reports" 2>/dev/null
    report="$SOURCE_DIR/reports/report.html"
    cat > "$report" <<EOF
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>cforge report</title></head>
<body>
<h1>Project report</h1>
<p>Generated at: $(date '+%Y-%m-%d %H:%M:%S')</p>
<ul>
  <li>.c files: ${#c_files[@]}</li>
  <li>.h files: ${#h_files[@]}</li>
  <li>Lines of code: $total_loc</li>
  <li>Executable size: $exec_size</li>
  <li>Last build: $last_build</li>
  <li>Last run: $last_run</li>
</ul>
</body>
</html>
EOF
    echo "report generated at: $report"
fi

log "info" "$SECONDS" 0 ""
exit 0
