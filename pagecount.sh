#!/bin/sh

if [ -z "$1" ]; then
    echo "Usage: $0 <pdf-file>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: file not found"
    exit 1
fi

if ! file "$FILE" | grep -qi "PDF"; then
    echo "Error: not a PDF file"
    exit 1
fi

if ! command -v pdfinfo >/dev/null 2>&1; then
    echo "Error: pdfinfo not found (install poppler-utils)" >&2
    exit 1
fi

PAGES=$(pdfinfo "$FILE" | awk -F': *' '/Pages:/ {print $2; exit}')

if [ -z "$PAGES" ]; then
    echo "Error: could not determine page count for $FILE" >&2
    exit 1
fi

echo "$PAGES"
