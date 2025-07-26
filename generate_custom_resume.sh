#!/bin/bash

# Usage: ./generate_custom_resume.sh CompanyName

COMPANY="$1"
if [ -z "$COMPANY" ]; then
  echo "Usage: $0 CompanyName"
  exit 1
fi

# Generate the PDF from resume.tex
pdflatex -interaction=nonstopmode resume.tex > /dev/null

if [ ! -f resume.pdf ]; then
  echo "Error: resume.pdf was not generated."
  exit 2
fi

# Format the company-specific filename
OUTFILE="custom_resumes/Mohamed_Abdelrahman_Resume_${COMPANY}.pdf"

# Move the generated PDF
mv resume.pdf "$OUTFILE"
echo "Custom resume generated: $OUTFILE" 