# Mohamed Abdelrahman's Resume

LaTeX template for my personal resume, customized for software engineering and technical roles. Personal info lives in `config.json`, so forking this for yourself is mostly a one-file edit — see Quick Start below.

Based off of [sb2nov/resume](https://github.com/sb2nov/resume/)

## Quick Start

1. **Install dependencies** (one-time, safe to re-run):
   ```bash
   ./setup_project_onetime.sh
   ```
   Installs LaTeX, `pdfinfo`, `file`, and `jq` (via `apt`/`brew`/`dnf`), and creates the local `info/projects/` and `info/job_listings/` folders.

2. **Make it yours** — edit [`config.json`](config.json) with your name, contact info, university, and graduation term. That's the only file you need to touch to re-personalize the template.

3. **Edit your resume content** in [`resume.tex`](resume.tex) (Experience, Projects, Leadership, etc.). Leave the `@@TOKEN@@` placeholders in the header/education alone — those are filled in from `config.json` automatically at build time.

4. **Build the PDF:**
   ```bash
   ./build_resume.sh          # resume.tex -> resume.pdf
   ./print_resume_render.sh   # plain-text-link print version -> print_resume.pdf
   ./pagecount.sh resume.pdf  # helper that counts pages without opening the file and warns if more than 1 page
   ```

5. **Publish the change** — once `resume.pdf` looks right:
   ```bash
   ./apply_changes_to_resume.sh
   ```
   Copies `resume.pdf` over the tracked `<resume_filename>.pdf` (from `config.json`).

6. **Tailoring for a specific job?** Drop the posting in `info/job_listings/`, then run the **`tailor-job-app`** skill (`/tailor-job-app CompanyName`) for the full routine: tailoring `resume.tex` from `base_resume.tex` under the 1-page rule, generating the company-specific copy via `generate_tailored_resume_copy.sh`, and — once you confirm you applied — logging the application (date, company, title, description, job type) to the Google Sheet tracker. See `.claude/skills/tailor-job-app/SKILL.md` for the full step-by-step.

## Resume Versions

- **[Current Resume](Mohamed_Abdelrahman_Resume.pdf)** - Latest version
- **[Print Version](print_resume.pdf)** - plain-text contact links, for printing on paper

## Repository structure

- `config.json` — your identity/config data (name, contact, university, graduation term, output filename). Edit this to personalize the template.
- `resume.tex` — the main resume, the active work-in-progress draft.
- `base_resume.tex` — an archive of every bullet/entry that's ever existed across versions; reference only, never built.
- `headers_for_print_resume.tex` — the plain-text-link header used for the print version. Never hand-edit a `print_resume.tex` — there isn't one to keep in sync; it's generated fresh each time.
- `resume_render.sh` — substitutes `@@TOKEN@@` placeholders in a `.tex` file with values from `config.json`. Called internally by the build scripts.
- `build_resume.sh [file]` — renders and compiles a `.tex` file into a PDF (defaults to `resume.tex`).
- `print_resume_render.sh` — creates `print_resume.pdf` by splicing `resume.tex`'s body with `headers_for_print_resume.tex`'s header into a transient `print_resume.tex`, then building it via `build_resume.sh`. The print PDF can never drift out of sync with the main resume's content.
- `apply_changes_to_resume.sh` — publishes `resume.pdf` as the tracked output PDF.
- `generate_tailored_resume_copy.sh CompanyName` — builds a company-specific tailored copy under `custom_resumes/`.
- `pagecount.sh <pdf>` — checks a PDF's page count (the resume must stay at 1 page).
- `setup_project_onetime.sh` — one-time dependency install and local folder setup.
- `info/` — gitignored, local-only material used when tailoring: `info/projects/` for personal project notes, `info/job_listings/` for saved job postings. Never committed.
- `custom_resumes/` — gitignored, generated tailored PDFs per company.

See `CLAUDE.md` for the full workflow reference.

## Original Template

Use the original template on Overleaf: [Jake's Resume](https://www.overleaf.com/latex/templates/jakes-resume/syzfjbzwjncs)
