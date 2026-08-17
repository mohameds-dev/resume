#!/bin/bash
# One-time environment setup for this repo's build scripts.
#
# Installs everything needed by:
#   build_resume.sh, pagecount.sh, apply_changes_to_resume.sh,
#   generate_tailored_resume_copy.sh
#
# Dependencies:
#   - pdflatex        (LaTeX -> PDF)          apt: texlive-latex-base texlive-latex-extra
#                                                    texlive-fonts-recommended texlive-fonts-extra
#                      (LaTeX -> PDF)          brew: --cask mactex-no-gui
#   - pdfinfo          (PDF page count)        apt: poppler-utils   brew: poppler
#   - file             (PDF type check)        apt: file            brew: file (usually preinstalled)
#
# Safe to re-run; only installs what's missing.

set -e

echo "Setting up build dependencies for resume project..."

need_pdflatex=1
need_pdfinfo=1
need_file=1

command -v pdflatex >/dev/null 2>&1 && need_pdflatex=0
command -v pdfinfo  >/dev/null 2>&1 && need_pdfinfo=0
command -v file      >/dev/null 2>&1 && need_file=0

if [ "$need_pdflatex" -eq 0 ] && [ "$need_pdfinfo" -eq 0 ] && [ "$need_file" -eq 0 ]; then
    echo "All dependencies already installed. Nothing to do."
    exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
    PACKAGES=""
    [ "$need_pdflatex" -eq 1 ] && PACKAGES="$PACKAGES texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra"
    [ "$need_pdfinfo" -eq 1 ] && PACKAGES="$PACKAGES poppler-utils"
    [ "$need_file" -eq 1 ] && PACKAGES="$PACKAGES file"

    echo "Detected apt (Debian/Ubuntu). Installing:$PACKAGES"
    sudo apt-get update
    # shellcheck disable=SC2086
    sudo apt-get install -y $PACKAGES

elif command -v brew >/dev/null 2>&1; then
    PACKAGES=""
    [ "$need_pdfinfo" -eq 1 ] && PACKAGES="$PACKAGES poppler"
    [ "$need_file" -eq 1 ] && PACKAGES="$PACKAGES file-formula"

    echo "Detected Homebrew (macOS). Installing:$PACKAGES"
    [ -n "$PACKAGES" ] && brew install $PACKAGES

    if [ "$need_pdflatex" -eq 1 ]; then
        echo "Installing MacTeX (this is large, ~4GB, and may take a while)..."
        brew install --cask mactex-no-gui
    fi

elif command -v dnf >/dev/null 2>&1; then
    PACKAGES=""
    [ "$need_pdflatex" -eq 1 ] && PACKAGES="$PACKAGES texlive-latex texlive-collection-fontsrecommended texlive-collection-fontsextra"
    [ "$need_pdfinfo" -eq 1 ] && PACKAGES="$PACKAGES poppler-utils"
    [ "$need_file" -eq 1 ] && PACKAGES="$PACKAGES file"

    echo "Detected dnf (Fedora/RHEL). Installing:$PACKAGES"
    sudo dnf install -y $PACKAGES

else
    echo "Error: no supported package manager found (apt-get, brew, dnf)." >&2
    echo "Please install manually: pdflatex (a LaTeX distribution), pdfinfo (poppler-utils), file" >&2
    exit 1
fi

echo
echo "Verifying installation..."
ok=1
for cmd in pdflatex pdfinfo file; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  OK   $cmd"
    else
        echo "  MISSING  $cmd"
        ok=0
    fi
done

if [ "$ok" -eq 1 ]; then
    echo
    echo "Setup complete. You can now run build_resume.sh, pagecount.sh, etc."
else
    echo
    echo "Some dependencies are still missing. Install them manually and re-run this script." >&2
    exit 1
fi
