---
name: tailor-job-app
description: Full job-application routine for this resume repo — parse a job listing, tailor resume.tex from base_resume.tex under the 1-page rule (build/pagecount/trim loop), generate the company-specific PDF via generate_tailored_resume_copy.sh, then prompt to log the application to the Google Sheet tracker via the google-sheets MCP. Use whenever tailoring the resume for a specific job posting or company, or asked to "apply the tailoring workflow" / "tailor for X".
---

# Job application routine

The full pipeline from job posting to tailored PDF to logged application. Run every
step in order — don't skip the page-count loop or the post-generation prompt.

Optional argument: a company name or a path under `info/job_listings/`. If neither is
given, ask the user which job listing to use (or ask them to paste the JD).

## Step 1 — Understand the role

Parse the job listing (a file in `info/job_listings/`, a pasted JD, or a saved HTML/mhtml
under `custom_resumes/<Company>/`). Extract:
- Company name and exact job title (as written in the posting)
- Employment type (full-time, intern, contract, etc.)
- Required/preferred skills and keywords
- A concise 1-2 sentence summary of the role (needed later for the sheet log)

If the source is a saved job-site HTML page and the visible body text looks like a
placeholder ("no longer accepting applications", a cookie banner, etc.), check for a
`schema.org` `JobPosting` block in `<script type="application/ld+json">` — job sites
routinely embed the full description there even after the visible page is stale. Look
for `description`, `title`, and `employmentType` keys in that JSON block.

## Step 2 — Tailor resume.tex

`base_resume.tex` is the bank of every bullet ever written across all versions — pull
from there, don't invent new content. Rules:

- Match terminology to the job description only where your experience genuinely
  supports it — no keyword-stuffing.
- Reword bullets to be punchy and direct. No corporate fluff.
- Prioritize relevance over completeness when cutting for space.
- Never invent skills, tools, or experience not present in `base_resume.tex`.
- Never touch `@@...@@` tokens — those are filled from `config.json` at build time.
- Target exactly ONE page. Trim bullets before removing whole sections.

**Trim order when cutting for space:** least relevant projects first → weaker bullets
within sections → older/less relevant roles. Don't cut evenly across sections — cut the
least relevant material first regardless of which section it's in.

## Step 3 — Build and enforce the 1-page rule

```bash
./build_resume.sh
./pagecount.sh resume.pdf
```

If the result is more than 1 page: go back to Step 2's trim order, shorten further, and
rebuild. Repeat until `pagecount.sh` reports 1 page — never ship a 2-page result.
Wrap-around lines that leave an orphaned trailing line are the most common cause of
spilling to a second page; check those first before cutting whole bullets.

## Step 4 — Generate the tailored copy

```bash
./generate_tailored_resume_copy.sh CompanyName
```

Always use this script to persist the tailored PDF under `custom_resumes/CompanyName/`.
Skipping it loses the tailoring, since `resume.tex` is meant to stay a general-purpose
work-bench draft rather than permanently drift toward one job. Pass the correct company
name so the output lands in the right directory.

## Step 5 — Prompt for the application log

Immediately after Step 4, every time, without being asked, say:

> Let me know if you applied, I'll fill out the job record with the following:
> - application date (today's date)
> - company name (easy)
> - job title (as in JD)
> - job description (concise description)
> - job type (selection, likely "Fulltime" now)

## Step 6 — Log the application (if the user confirms they applied)

Applications are tracked in a Google Sheet via the global `google-sheets` MCP server
(user-scoped in Claude Code, defined outside this repo — see
`~/.claude/scripts/README.md` for how it resolves this project's credentials from
`keys/`).

- **Spreadsheet ID:** `1Fti9oliQw_ws4ouci3CvCb3hY2IqNZv79_-DJc-jnHs` (same as
  `keys/links.json` → `google_sheet_with_jobs_tracking`)
- **Sheet/tab name:** `Form Responses 1`
- **Column layout (A:J)** — header row 1:

  | Col | Header | What to write |
  |---|---|---|
  | A | Timestamp | leave blank (Google Form auto-fills this on real form submissions) |
  | B | Application date | today's date, `M/D/YYYY` |
  | C | Company name | e.g. `Cisco` |
  | D | Job title | as written in the JD |
  | E | Job Type | e.g. `Fulltime` (no enforced dropdown on the sheet itself — match what the user says, default `Fulltime` for the current search) |
  | F | Hiring manager name | leave blank unless known |
  | G | Relevant skills | leave blank unless asked |
  | H | Information about company and/or job description | the concise summary from Step 1 |
  | I | Cover letter focus question | leave blank unless asked |
  | J | Latest update | `Applied` |

Call `mcp__google-sheets__sheets_append_values` with:
- `spreadsheetId`: the ID above
- `range`: `"Form Responses 1!A:J"`
- `values`: `[[<row matching the columns above>]]`
- `valueInputOption`: `"USER_ENTERED"`

**Tool gotchas** (from `mcp-gsheets`): params are camelCase (`spreadsheetId`, not
`spreadsheet_id`); `sheets_get_data_validation` needs a separate `sheetName` arg, not
folded into `range`.

**If `mcp__google-sheets__*` tools aren't in the current session's tool list** (the
server was registered mid an older session), tell the user to restart Claude Code — or,
as a fallback, speak MCP JSON-RPC directly over stdio to
`~/.claude/scripts/google-sheets-mcp-launcher.sh` (`initialize` → `tools/call`).
