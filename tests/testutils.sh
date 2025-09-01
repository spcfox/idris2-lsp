#!/bin/sh

# This script is intended to be sourced from test scripts.
# It provides a number of test utilities.
# Usage: . ../../testutils.sh

idris2_lsp="$1"
WORKING_DIR=$(pwd)

# Delete build files between runs to prevent unexpected differences.
# As this is at the top-level, this is run when this script is imported.
rm -rf build

format_request() {
    printf "Content-Length: %d\r\n\r\n%s" "$(printf "%s" "$request" | wc -c)" "$1"
}

substitute_vars() {
    file="$1"
    input="$2"
    sed \
        -e "s|{WORKING_DIR}|$WORKING_DIR|g" \
        -e "s|{FILE}|$file|g" \
        "$input"
}

format_jsonl() {
    file="$1"
    input="$2"
    substitute_vars "$file" "$input" | while IFS= read -r line; do
        request=$(printf "%s" "$line" | tr -d ' \t\n\r')
        [ -z "$request" ] && continue
        format_request "$request"
    done
}

clean_paths() {
    sed \
        -e "s|$WORKING_DIR|{WORKING_DIR}|g" \
        -e "s|Content-Length: [0-9]\{1,\}|Content-Length: N|g"
}

run_lsp_no_clean() {
    format_jsonl "$1" "$2" | $idris2_lsp
}

# Usage: run_lsp <file> <input>
run_lsp() {
    run_lsp_no_clean "$1" "$2" | clean_paths
}
