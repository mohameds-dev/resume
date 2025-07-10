#!/bin/bash

echo "Applying changes to resume..."

if [ ! -f "resume.pdf" ]; then
    echo "Error: resume.pdf not found in current directory"
    exit 1
fi

if [ -f "Mohamed_Abdelrahman_Resume_2025.pdf" ]; then
    echo "Removing old resume: Mohamed_Abdelrahman_Resume_2025.pdf"
    rm "Mohamed_Abdelrahman_Resume_2025.pdf"
fi

echo "Copying resume.pdf to Mohamed_Abdelrahman_Resume_2025.pdf"
cp "resume.pdf" "Mohamed_Abdelrahman_Resume_2025.pdf"

echo "Resume update completed successfully!"