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

rm -f $resume_file.aux $resume_file.log $resume_file.out

exit $status