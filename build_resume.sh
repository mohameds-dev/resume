#!/bin/bash

resume_file="resume"
if [ $# -eq 1 ]; then
    resume_file=$1
    resume_file=${resume_file%.tex}
fi

output=$(pdflatex -interaction=nonstopmode $resume_file.tex 2>&1)
status=$?

if [ $status -ne 0 ]; then
    echo "$output"
fi

# Check page count if PDF was generated successfully
if [ $status -eq 0 ] && [ -f "$resume_file.pdf" ]; then
    page_count=$(./pagecount.sh "$resume_file.pdf" 2>/dev/null)
    if [ -n "$page_count" ] && [ "$page_count" -gt 1 ]; then
        echo "Warning: PDF has $page_count pages (expected 1 page)" >&2
    fi
fi

rm -f $resume_file.aux $resume_file.log $resume_file.out

exit $status