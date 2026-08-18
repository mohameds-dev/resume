#!/bin/bash

resume_file="resume"
if [ $# -eq 1 ]; then
    resume_file=$1
    resume_file=${resume_file%.tex}
fi

rendered_file="${resume_file}_rendered"

./resume_render.sh "$resume_file.tex" "$rendered_file.tex" || exit 1

output=$(pdflatex -interaction=nonstopmode $rendered_file.tex 2>&1)
status=$?

if [ $status -ne 0 ]; then
    echo "$output"
fi

# Check page count if PDF was generated successfully
if [ $status -eq 0 ] && [ -f "$rendered_file.pdf" ]; then
    mv "$rendered_file.pdf" "$resume_file.pdf"
    page_count=$(./pagecount.sh "$resume_file.pdf")
    if [ -n "$page_count" ] && [ "$page_count" -gt 1 ]; then
        echo "Warning: PDF has $page_count pages (expected 1 page)" >&2
    fi
fi

rm -f $rendered_file.tex $rendered_file.aux $rendered_file.log $rendered_file.out

exit $status
