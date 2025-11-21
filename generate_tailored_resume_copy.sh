#!/bin/bash

# Usage: ./generate_tailored_resume_copy.sh CompanyName [spring|fall]

COMPANY="$1"
GRAD_TERM="$2"

if [ -z "$COMPANY" ] || [ -z "$GRAD_TERM" ]; then
  echo "Usage: $0 CompanyName [spring|fall]"
  echo "  spring -> May 2026"
  echo "  fall   -> Dec 2026"
  exit 1
fi

# Set graduation date based on term
if [ "$GRAD_TERM" = "fall" ]; then
  GRAD_DATE="Dec 2026"
elif [ "$GRAD_TERM" = "spring" ]; then
  GRAD_DATE="May 2026"
else
  echo "Error: Invalid graduation term. Use 'spring' or 'fall'"
  echo "  spring -> May 2026"
  echo "  fall   -> Dec 2026"
  exit 1
fi

# Create a temporary copy of resume.tex with the graduation date replaced
TEMP_TEX="resume_temp.tex"
cp resume.tex "$TEMP_TEX"

# Replace the graduation date in the temporary file
# Pattern: {University of Houston}{May 2026} or {University of Houston}{Dec 2026}
sed -i "s/{University of Houston}{[A-Z][a-z][a-z] 2026}/{University of Houston}{$GRAD_DATE}/" "$TEMP_TEX"

# Generate the PDF from the temporary resume.tex
pdflatex -interaction=nonstopmode "$TEMP_TEX" > /dev/null

if [ ! -f resume_temp.pdf ]; then
  echo "Error: resume.pdf was not generated."
  # Clean up temporary files on error
  rm -f "$TEMP_TEX" resume_temp.aux resume_temp.log resume_temp.out
  exit 2
fi

mkdir -p custom_resumes
mkdir -p custom_resumes/$COMPANY

# Format the company-specific filename
OUTFILE="custom_resumes/$COMPANY/Mohamed_Abdelrahman_Resume.pdf"

# Move the generated PDF
mv resume_temp.pdf "$OUTFILE"

# Clean up temporary files
rm -f "$TEMP_TEX" resume_temp.aux resume_temp.log resume_temp.out

echo "Custom resume generated: $OUTFILE (Graduation: $GRAD_DATE)" 