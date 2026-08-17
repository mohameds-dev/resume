#!/bin/bash

echo "Applying changes to resume..."

if [ ! -f "resume.pdf" ]; then
    echo "Error: resume.pdf not found in current directory"
    exit 1
fi

RESUME_FILENAME=$(jq -r '.resume_filename' config.json)
TARGET="${RESUME_FILENAME}.pdf"

if [ -f "$TARGET" ]; then
    echo "Removing old resume: $TARGET"
    rm "$TARGET"
fi

echo "Copying resume.pdf to $TARGET"
cp "resume.pdf" "$TARGET"

echo "Resume update completed successfully!"
