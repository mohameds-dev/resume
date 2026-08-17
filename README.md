# Mohamed Abdelrahman's Resume

LaTeX template for my personal resume, customized for software engineering and technical roles.

Based off of [sb2nov/resume](https://github.com/sb2nov/resume/)

## Resume Versions

- **[Current Resume (2025)](Mohamed_Abdelrahman_Resume.pdf)** - Latest version
- **[Print Version](print_resume.pdf)**

## Usage

This repository contains:

- LaTeX source files for resume generation
- Build scripts for automated resume creation
- Custom resume generation for specific job applications (create a separate .pdf based on resume.tex)

### Setup

Before using the build scripts, install their dependencies (LaTeX, `pdfinfo`, `file`, `jq`) with:

```bash
./setup_project_onetime.sh
```

This is a one-time step (safe to re-run) that works on Debian/Ubuntu (`apt`), macOS (`brew`), and Fedora/RHEL (`dnf`). It also creates the local `info/projects/` and `info/job_listings/` folders (gitignored) used when tailoring the resume.

### Using this as your own template

All personal/identity info (name, contact info, university, graduation dates, output filename) lives in [`config.json`](config.json) — edit that one file to make this resume yours. Build scripts render `resume.tex`'s `@@TOKEN@@` placeholders from it automatically; see `CLAUDE.md` for details on the full workflow.

## Original Template

Use the original template on Overleaf: [Jake's Resume](https://www.overleaf.com/latex/templates/jakes-resume/syzfjbzwjncs)
