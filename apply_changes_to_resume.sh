#!/bin/bash

echo "Applying changes to resume..."

if [ ! -f "resume.pdf" ]; then
    echo "Error: resume.pdf not found in current directory"
    exit 1
fi

if [ -f "Mohamed_Abdelrahman_Resume.pdf" ]; then
    echo "Removing old resume: Mohamed_Abdelrahman_Resume.pdf"
    rm "Mohamed_Abdelrahman_Resume.pdf"
fi

echo "Copying resume.pdf to Mohamed_Abdelrahman_Resume.pdf"
cp "resume.pdf" "Mohamed_Abdelrahman_Resume.pdf"

echo "Resume update completed successfully!"