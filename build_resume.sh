#!/bin/bash

output=$(pdflatex resume.tex 2>&1)
status=$?

if [ $status -ne 0 ]; then
    echo "$output"
fi

exit $status