#!/bin/bash

resume_file="resume"

output=$(pdflatex $resume_file.tex 2>&1)
status=$?

if [ $status -ne 0 ]; then
    echo "$output"
fi

rm -f $resume_file.aux $resume_file.log $resume_file.out

exit $status