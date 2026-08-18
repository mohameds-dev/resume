#!/bin/bash
# Renders a resume .tex template by substituting @@TOKEN@@ placeholders with values from config.json.
# Usage: ./resume_render.sh <input.tex> <output.tex>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/config.json"

INPUT="$1"
OUTPUT="$2"

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: $0 <input.tex> <output.tex>" >&2
    exit 1
fi

if [ ! -f "$CONFIG" ]; then
    echo "Error: config.json not found at $CONFIG" >&2
    exit 1
fi

# Escape sed metacharacters (\ and &) so values substitute in literally.
escape() { printf '%s' "$1" | sed -e 's/[\&]/\\&/g'; }

# Strips the protocol (and leading "www.") for compact plain-text display,
# e.g. for headers_for_print_resume.tex, where the full https://... would wrap.
bare() { printf '%s' "$1" | sed -e 's#^https\?://##' -e 's#^www\.##' -e 's#/$##'; }

NAME=$(escape "$(jq -r '.name' "$CONFIG")")
EMAIL=$(escape "$(jq -r '.email' "$CONFIG")")
PHONE=$(escape "$(jq -r '.phone' "$CONFIG")")
LINKEDIN_URL=$(escape "$(jq -r '.linkedin_url' "$CONFIG")")
GITHUB_URL=$(escape "$(jq -r '.github_url' "$CONFIG")")
PORTFOLIO_URL=$(escape "$(jq -r '.portfolio_url' "$CONFIG")")
UNIVERSITY=$(escape "$(jq -r '.university' "$CONFIG")")
GRAD_DATE=$(escape "$(jq -r '.graduation_term' "$CONFIG")")
LINKEDIN_BARE=$(escape "$(bare "$(jq -r '.linkedin_url' "$CONFIG")")")
GITHUB_BARE=$(escape "$(bare "$(jq -r '.github_url' "$CONFIG")")")
PORTFOLIO_BARE=$(escape "$(bare "$(jq -r '.portfolio_url' "$CONFIG")")")

sed \
    -e "s|@@NAME@@|$NAME|g" \
    -e "s|@@EMAIL@@|$EMAIL|g" \
    -e "s|@@PHONE@@|$PHONE|g" \
    -e "s|@@LINKEDIN_URL_BARE@@|$LINKEDIN_BARE|g" \
    -e "s|@@GITHUB_URL_BARE@@|$GITHUB_BARE|g" \
    -e "s|@@PORTFOLIO_URL_BARE@@|$PORTFOLIO_BARE|g" \
    -e "s|@@LINKEDIN_URL@@|$LINKEDIN_URL|g" \
    -e "s|@@GITHUB_URL@@|$GITHUB_URL|g" \
    -e "s|@@PORTFOLIO_URL@@|$PORTFOLIO_URL|g" \
    -e "s|@@UNIVERSITY@@|$UNIVERSITY|g" \
    -e "s|@@GRAD_DATE@@|$GRAD_DATE|g" \
    "$INPUT" > "$OUTPUT"
