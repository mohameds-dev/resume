#!/bin/bash
# Creates print_resume.pdf: resume.tex's body with its header swapped for
# headers_for_print_resume.tex's plain-text-link header (for printing on paper,
# where clickable links are useless). Generates a transient print_resume.tex
# and delegates the actual render+compile to build_resume.sh, so print_resume.pdf
# can never drift out of sync with resume.tex's content.

set -e

HEADERS_FILE="headers_for_print_resume.tex"
GENERATED_TEX="print_resume.tex"

if [ ! -f "$HEADERS_FILE" ]; then
    echo "Error: $HEADERS_FILE not found" >&2
    exit 1
fi

cleanup() {
    rm -f "$GENERATED_TEX"
}
trap cleanup EXIT

awk -v headers_file="$HEADERS_FILE" '
    !replaced && /^\\begin\{center\}/ {
        while ((getline line < headers_file) > 0) print line
        replaced = 1
        skipping = 1
        next
    }
    skipping {
        if ($0 ~ /^\\end\{center\}/) skipping = 0
        next
    }
    { print }
' resume.tex > "$GENERATED_TEX"

./build_resume.sh print_resume
