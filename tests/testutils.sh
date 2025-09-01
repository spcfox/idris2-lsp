#!/bin/sh

# This script is intended to be sourced from test scripts.
# It provides a number of test utilities.
# Usage: . ../../testutils.sh

idris2_lsp="$1"

# Delete build files between runs to prevent unexpected differences.
# As this is at the top-level, this is run when this script is imported.
rm -rf build

format_request() {
    printf "Content-Length: %d\r\n\r\n%s" "$(printf "%s" "$request" | wc -c)" "$1"
}

format_jsonl() {
    input="$1"
    while IFS= read -r line; do
        request=$(printf "%s" "$line" | tr -d ' \t\n\r')
        [ -z "$request" ] && continue
        format_request "$request"
    done <"$input"
}

run_lsp() {
    format_jsonl "$1" | $idris2_lsp
}
