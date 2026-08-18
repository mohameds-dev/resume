#!/bin/bash
# One-time environment setup for this repo's build scripts.
#
# Installs everything needed by:
#   build_resume.sh, pagecount.sh, apply_changes_to_resume.sh,
#   generate_tailored_resume_copy.sh, print_resume_render.sh
#
# Every dependency is attempted independently, so one failed install doesn't
# block the rest -- each failure is reported with what that dependency is
# for, and a final summary lists anything still missing.
#
# Safe to re-run; only installs what's missing.

echo "Setting up build dependencies for resume project..."

# Create the (gitignored) local info tree: personal project notes and
# job-listing files that scripts/config.json reference but never version.
mkdir -p info/projects info/job_listings
echo "Created info/projects/ and info/job_listings/ (gitignored, local-only)."
echo

PKG_MANAGER=""
if command -v apt-get >/dev/null 2>&1; then
    PKG_MANAGER="apt"
elif command -v brew >/dev/null 2>&1; then
    PKG_MANAGER="brew"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
fi

if [ -z "$PKG_MANAGER" ]; then
    echo "Error: no supported package manager found (apt-get, brew, dnf)." >&2
    echo "Please install manually: pdflatex (a LaTeX distribution), pdfinfo (poppler-utils), file, jq" >&2
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"

if [ "$PKG_MANAGER" = "apt" ]; then
    echo "Refreshing apt package index..."
    sudo apt-get update || echo "Warning: 'apt-get update' failed; installs below may use a stale index." >&2
fi

failed=0

# install_dep <command> <what it's for> <apt-packages> <brew-packages> <dnf-packages>
# Installs <command> via the detected package manager if it's missing.
# Prints a clear error naming the command and its purpose if the install
# fails, and continues on to the next dependency either way.
install_dep() {
    local cmd="$1" purpose="$2" apt_pkgs="$3" brew_pkgs="$4" dnf_pkgs="$5"

    if command -v "$cmd" >/dev/null 2>&1; then
        echo "OK       $cmd already installed -- $purpose"
        return 0
    fi

    local pkgs=""
    case "$PKG_MANAGER" in
        apt)  pkgs="$apt_pkgs" ;;
        brew) pkgs="$brew_pkgs" ;;
        dnf)  pkgs="$dnf_pkgs" ;;
    esac

    if [ -z "$pkgs" ]; then
        echo "ERROR    no $PKG_MANAGER package known for $cmd -- needed for: $purpose. Install it manually and re-run this script." >&2
        failed=1
        return 1
    fi

    echo "Installing $cmd ($purpose)..."
    case "$PKG_MANAGER" in
        apt)  sudo apt-get install -y $pkgs ;;
        brew) brew install $pkgs ;;
        dnf)  sudo dnf install -y $pkgs ;;
    esac

    if command -v "$cmd" >/dev/null 2>&1; then
        echo "OK       $cmd installed"
        return 0
    else
        echo "ERROR    failed to install $cmd -- needed for: $purpose. Install it manually and re-run this script." >&2
        failed=1
        return 1
    fi
}

# pdflatex installs differently per package manager (brew uses a cask, not a
# formula), so it's handled directly rather than through install_dep.
PDFLATEX_PURPOSE="compiles the LaTeX resume (.tex) into a PDF -- used by build_resume.sh, print_resume_render.sh, generate_tailored_resume_copy.sh"
if command -v pdflatex >/dev/null 2>&1; then
    echo "OK       pdflatex already installed -- $PDFLATEX_PURPOSE"
else
    echo "Installing pdflatex ($PDFLATEX_PURPOSE)..."
    case "$PKG_MANAGER" in
        apt)
            sudo apt-get install -y texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra
            ;;
        brew)
            echo "This installs MacTeX (~4GB) and may take a while..."
            brew install --cask mactex-no-gui
            ;;
        dnf)
            sudo dnf install -y texlive-latex texlive-collection-fontsrecommended texlive-collection-fontsextra
            ;;
    esac

    if command -v pdflatex >/dev/null 2>&1; then
        echo "OK       pdflatex installed"
    else
        echo "ERROR    failed to install pdflatex -- needed for: $PDFLATEX_PURPOSE. Install a LaTeX distribution manually and re-run this script." >&2
        failed=1
    fi
fi

install_dep pdfinfo "reports a PDF's page count -- used by pagecount.sh to enforce the 1-page resume limit" \
    "poppler-utils" "poppler" "poppler-utils"

install_dep file "verifies a build output is actually a PDF -- used by pagecount.sh" \
    "file" "file-formula" "file"

install_dep jq "reads config.json and substitutes @@TOKEN@@ placeholders -- used by resume_render.sh, apply_changes_to_resume.sh, generate_tailored_resume_copy.sh" \
    "jq" "jq" "jq"

echo
echo "Verifying installation..."
ok=1
for cmd in pdflatex pdfinfo file jq; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  OK       $cmd"
    else
        echo "  MISSING  $cmd"
        ok=0
    fi
done

if [ "$ok" -eq 1 ] && [ "$failed" -eq 0 ]; then
    echo
    echo "Setup complete. You can now run build_resume.sh, pagecount.sh, etc."
    exit 0
else
    echo
    echo "Some dependencies are still missing (see ERROR lines above for what each one is for). Install them manually and re-run this script." >&2
    exit 1
fi
