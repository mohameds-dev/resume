#!/bin/bash
# Renders a resume .tex template by substituting @@TOKEN@@ placeholders with values from config.json.
# Usage: ./render_resume.sh <input.tex> <output.tex> [graduation_term]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/config.json"

INPUT="$1"
OUTPUT="$2"
GRAD_TERM="$3"

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: $0 <input.tex> <output.tex> [graduation_term]" >&2
    exit 1
fi

if [ ! -f "$CONFIG" ]; then
    echo "Error: config.json not found at $CONFIG" >&2
    exit 1
fi

if [ -z "$GRAD_TERM" ]; then
    GRAD_TERM=$(jq -r '.default_graduation_term' "$CONFIG")
fi

GRAD_DATE=$(jq -r --arg term "$GRAD_TERM" '.graduation_dates[$term] // empty' "$CONFIG")
if [ -z "$GRAD_DATE" ]; then
    echo "Error: unknown graduation term '$GRAD_TERM'. Available terms:" >&2
    jq -r '.graduation_dates | to_entries[] | "  \(.key) -> \(.value)"' "$CONFIG" >&2
    exit 1
fi

# Escape sed metacharacters (\ and &) so values substitute in literally.
escape() { printf '%s' "$1" | sed -e 's/[\&]/\\&/g'; }

NAME=$(escape "$(jq -r '.name' "$CONFIG")")
EMAIL=$(escape "$(jq -r '.email' "$CONFIG")")
PHONE=$(escape "$(jq -r '.phone' "$CONFIG")")
LINKEDIN_URL=$(escape "$(jq -r '.linkedin_url' "$CONFIG")")
GITHUB_URL=$(escape "$(jq -r '.github_url' "$CONFIG")")
PORTFOLIO_URL=$(escape "$(jq -r '.portfolio_url' "$CONFIG")")
UNIVERSITY=$(escape "$(jq -r '.university' "$CONFIG")")
GRAD_DATE=$(escape "$GRAD_DATE")

sed \
    -e "s|@@NAME@@|$NAME|g" \
    -e "s|@@EMAIL@@|$EMAIL|g" \
    -e "s|@@PHONE@@|$PHONE|g" \
    -e "s|@@LINKEDIN_URL@@|$LINKEDIN_URL|g" \
    -e "s|@@GITHUB_URL@@|$GITHUB_URL|g" \
    -e "s|@@PORTFOLIO_URL@@|$PORTFOLIO_URL|g" \
    -e "s|@@UNIVERSITY@@|$UNIVERSITY|g" \
    -e "s|@@GRAD_DATE@@|$GRAD_DATE|g" \
    "$INPUT" > "$OUTPUT"
