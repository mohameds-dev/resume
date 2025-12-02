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

pdfinfo "$FILE" 2>/dev/null | awk -F': *' '/Pages:/ {print $2; exit}'
