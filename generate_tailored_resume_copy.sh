#!/bin/bash

# Usage: ./generate_tailored_resume_copy.sh CompanyName

COMPANY="$1"

if [ -z "$COMPANY" ]; then
  echo "Usage: $0 CompanyName"
  exit 1
fi

# Create a temporary copy of resume.tex with config values substituted in
TEMP_TEX="resume_temp.tex"
./resume_render.sh resume.tex "$TEMP_TEX" || exit 1

# Generate the PDF from the temporary resume.tex
pdflatex -interaction=nonstopmode "$TEMP_TEX" > /dev/null

if [ ! -f resume_temp.pdf ]; then
  echo "Error: resume.pdf was not generated."
  # Clean up temporary files on error
  rm -f "$TEMP_TEX" resume_temp.aux resume_temp.log resume_temp.out
  exit 2
fi

mkdir -p custom_resumes
mkdir -p "custom_resumes/$COMPANY"

# Format the company-specific filename
RESUME_FILENAME=$(jq -r '.resume_filename' config.json)
OUTFILE="custom_resumes/$COMPANY/${RESUME_FILENAME}.pdf"

# Move the generated PDF
mv resume_temp.pdf "$OUTFILE"

# Clean up temporary files
rm -f "$TEMP_TEX" resume_temp.aux resume_temp.log resume_temp.out

echo "Custom resume generated: $OUTFILE"
