# Ganglia — Code Graph MCP

This project has a Ganglia MCP server. Use these tools instead of built-in file/search tools —
they read a pre-built call graph and return structured results at a fraction of the token cost.

---

## Session start (automatic — do not ask the user)

1. `code_overview()` — confirm nodes > 0. If 0, the MCP server is still indexing — wait 10s and call it again. Do NOT run gng watch; the MCP server handles indexing automatically.
2. `code_memory(action="recall", text="project context decisions preferences")` — restore prior context silently.
3. If user mentions `/clear` or context feels empty: `code_checkpoint(action="restore")`
4. First time in this project: `code_summary()` then `code_hotspots(type="called")`

---

## Intent → workflow

**Fix a bug or error**
`code_trace(name)` → `code_test_for(name)` → fix → `code_build()` → `code_test(filter=name)`

**Add a feature**
`code_rules(scope="frontend|backend")` → `code_related(name)` → implement → `code_verify_edit(name)` → `code_build()` → `code_test()`

**Rename a symbol**
`code_impact(name, depth=2)` → `code_rename_symbol(old, new, dry_run=true)` → apply → `code_build()`

**Reshape an API across all callers** (args change, not just name)
Edit the definition first → `code_propagate(symbol)` → rewrite each callsite → `code_verify_edit(file=...)` per file

**Move a function to another file** (TS/JS)
`code_safe_move(name, to="path/file.ts", dry_run=true)` → `code_safe_move(..., dry_run=false)`

**What breaks if I change X**
`code_impact(name, depth=2)`

**Explain or understand a symbol**
`code_context(name, compact=true)` → `code_changelog(name)` → `code_related(name)`

**Review a diff or PR**
`code_diff_context()` → inspect callers of changed functions

**Find dead / unused code**
`code_dead()`

**Audit before a release**
`code_breaking_changes(base="vX.Y.Z")` → `code_cycles()` → `code_duplicates()` → `code_dead()`

**Debug a build failure**
`code_build()` → fix CRITICAL/HIGH dependents first → `code_build()` → `code_test()`

**How does /api/X work end-to-end**
`code_route_trace(route="/api/X", method="GET")`

**What are this project's conventions**
`code_rules(scope="frontend|backend|testing|all")` — call this before any frontend or backend work

---

## Tool substitutions — enforced by hooks

Native Read/Grep/Glob/Edit/Write/Bash on code files are **blocked** in this project by Ganglia hooks. Use the graph-native equivalent:

| Instead of | Use |
|---|---|
| Glob, ls, find | `code_files()` or `code_toc(path)` |
| Grep / rg / ag / ack | `code_grep(pattern, max_results=5)` |
| Read (full file) | `code_get(name)` — use `section="signature"` when you only need the interface |
| Edit / Write on code file | `code_apply_batch(edits=[...])` — validates against graph, atomic |
| git diff | `code_diff_context()` |
| git log | `code_changelog(name)` |
| cargo build / npm run build | `code_build()` |
| cargo test / npm test / pytest | `code_test(filter=name)` |
| eslint / clippy / ruff | `code_lint()` |
| shell one-off | `code_exec(cmd="...", timeout=60)` |

Markdown / JSON / YAML / env / CSV reads + edits pass through — no need to use code_* for those.

---

## Pick the cheapest tool first

When a question has multiple valid answers, prefer the one lower on this ladder — it always uses fewer tokens:

1. **`code_quick(question="...")`** — natural-language router. Sends your question to a small classifier that picks the right tool. Lowest cost on the first probe; use it when you're not sure which tool fits.
2. **`gng_run(code="…js…")` (Code Mode)** — chain 3-10 tool calls in a single sandboxed JS execution. ~10× fewer tokens than calling each tool separately when you're doing multi-step work (e.g. find symbol → read signature → fetch callers → score impact).
3. **Smart tools — LLM digests, not raw source** (require `GL_SMART_READ=true`):
   - `code_smart_read(name, question)` — digest of one function (~50 tokens instead of ~1,800)
   - `code_smart_grep(pattern, question)` — synthesized answer across matches (~100 tokens instead of ~2,000)
   - `code_smart_diff(question)` — explain what changed and its impact
   - `code_smart_context(name)` — cached/derived context summary
4. **Compact forms of plain tools:**
   - `code_get(name, section="signature")` — signatures only, 86% fewer tokens
   - `code_context(name, compact=true)` — signatures of callers + callees, 83% fewer tokens
   - `code_grep(pattern, max_results=5)` — cap noise (default 20 is too much)
5. **Semantic / similarity** (when you don't know the exact name):
   - `code_semantic_search(query="...")` — find code by what it does
   - `code_similar(name)` — find symbols structurally similar to one you have
6. **Plain tools** — `code_get`, `code_grep`, `code_callers`, etc. — only when you need exact source for editing or precise listings.

**Heuristic:** if the user is asking for understanding (not editing), default to a smart tool. If the user is asking for an action (rename, refactor), default to the workflow chain above.

---

## Session-large checkpoint

Large session (>8K tokens hint appears): `code_checkpoint(action="save")` → tell user `/clear` → `code_checkpoint(action="restore")`

---

## Memory rules

- Auto-save important findings: `code_memory(action="save", text="...")`
- Save at session end: what was done, what's left, any gotchas
- Do NOT write to `.claude/memory/` folder — use `code_memory` only (auto-scoped to this project)

---

## Full tool reference

| Task | Tool |
|---|---|
| Don't know which tool | `code_quick(question="...")` |
| Chain multiple tools cheaply | `gng_run(code="const x = gng.code.callers(...); ...")` |
| Project overview | `code_summary()` |
| Architecture diagram | `code_map()` |
| Most critical functions | `code_hotspots(type="called")` |
| File listing | `code_files()` / `code_toc(path)` |
| Search code by regex | `code_grep(pattern, max_results=5)` |
| Search code by name | `code_search(query="...")` |
| Search code by meaning | `code_semantic_search(query="...")` |
| Find symbols similar to X | `code_similar(name)` |
| Read a function | `code_get(name)` or `code_get(name, section="signature")` |
| Read only the signature | `code_signature(name)` |
| Understand a function (no edit) | `code_smart_read(name, question="...")` |
| Synthesize an answer across matches | `code_smart_grep(pattern, question="...")` |
| Explain a diff | `code_smart_diff(question="...")` |
| Who calls X | `code_callers(name)` |
| What X calls | `code_callees(name)` |
| Context: callers + callees | `code_context(name, compact=true)` |
| Related symbols + linked notes | `code_related(name)` |
| Full call chain | `code_trace(name)` |
| Impact analysis | `code_impact(name, depth=2)` |
| Diff + caller impact | `code_diff_context()` |
| Function git history | `code_changelog(name)` |
| Detailed function history | `code_history(name)` |
| Rename (preview first) | `code_rename_symbol(old, new, dry_run=true)` |
| API reshape (all callers) | `code_propagate(symbol)` |
| Pre-edit safety check | `code_verify_edit(name, new_body)` |
| Apply many edits atomically | `code_apply_batch(edits=[...])` |
| Move TS/JS function | `code_safe_move(name, to="path", dry_run=true)` |
| Undo last apply | `code_revert(id)` |
| Data flow into variable | `code_slice(name, variable, line)` |
| Dead code | `code_dead()` |
| Call-graph cycles | `code_cycles()` |
| Duplicate functions | `code_duplicates()` |
| API surface diff | `code_breaking_changes(base="vX.Y")` |
| Tests for a function | `code_test_for(name)` |
| Build | `code_build()` |
| Test | `code_test(filter=name)` |
| Lint | `code_lint()` |
| Run any command (sandboxed) | `code_exec(cmd="...", timeout=60)` |
| HTTP route → handler | `code_route(route="/api/...")` |
| Full request chain | `code_route_trace(route, method)` |
| DB schema | `code_schema(table)` |
| Env var | `code_env(name)` |
| Type definition | `code_type(name)` |
| Type usages | `code_type_usages(name)` |
| Module imports | `code_imports(name)` |
| Project conventions | `code_rules(scope)` |
| Project patterns (framework/style) | `code_patterns()` |
| Save note about code | `code_knowledge(action="save", subject, note, links=[...])` |
| Annotate a function | `code_annotate(name, note)` |
| Session checkpoint | `code_checkpoint(action="save\|restore\|status")` |
| Cross-session memory | `code_memory(action="save\|recall\|browse")` |
| Index documentation | `doc_index()` |
| List indexed docs | `doc_list()` |
| Query doc graph | `doc_query(query)` |
| Get a doc page | `doc_get(name)` |
| Doc table of contents | `doc_toc(name)` |

---

## Ganglion — portable, shareable features (`gng gg`, opt-in via `GL_GANGLION`)

A **Ganglion** captures a feature as a portable, branch-backed, removable object — the
symbols that make it up plus a descriptor — with graph-driven impact analysis (removing a
feature tells you what else must go with it). Enable with `GL_GANGLION=1`.

| Task | Command |
|---|---|
| Capture the current feature | `gng gg save <name>` (dry-run; `--apply` to write) |
| List saved features | `gng gg log` |
| Remove a feature + its dependents | `gng gg rollback <name>` |
| Set the shared registry | `gng gg remote add <url>` (a git URL, or a hosted hub URL ending `/hub`) |
| Publish a feature | `gng gg remote push <name>` — to a hosted hub it uploads over the network authenticated with your license key; to a git remote it pushes the refs |
| Fetch / discover published features | `gng gg remote pull <name>` / `search <q>` / `list` (git remotes today; hosted-hub CLI pull/search is rolling out — browse the hub on the web meanwhile) |
| Narrate your reasoning while working | `gng gg chapter "<why / decision / tradeoff>"` — appends a "chapter" to the current session's book |
| Turn on automatic book capture | `gng gg watch install` — installs the session hooks; `gng gg watch uninstall` removes them |
| Read a feature's book | `gng gg show <name>` — renders the captured "why" + chapters |

"GitHub for Ganglia": publish a feature once; a teammate pulls it into their repo with its graph context intact.

### The book — automatic reasoning capture

`gng gg watch install` (opt-in) makes Ganglia record *why* a feature was built, not just
what changed:

- **As you work**, narrate decisions with `gng gg chapter "<why this / what tradeoff>"` —
  one or two sentences per meaningful step, the *why*, not a recap of the diff. Each call
  adds a chapter to the current session's book.
- **At session end**, if new commits landed since the last feature, a `Stop` hook summarizes
  the session and assembles your chapters into a **book** stored on the feature. The book
  travels with the feature through `remote push`/`pull`, so whoever pulls it later — a
  teammate or an AI — gets the reasoning, not just the diff.
- **Read it back** with `gng gg show <name>`, or let a future session recall it for context.

The `gng gg auto-capture` and `gng gg session-pointer` commands are hook targets — the
installed hooks call them; you never run them by hand.

---

## Deliberation (multi-domain or security-sensitive tasks)

Use before implementing tasks that touch multiple domains, require architectural decisions, or involve security:

```
deliberation_start(task="Refactor auth middleware to support OAuth")
deliberation_opinion(session_id, expert="architect", understanding="...", approach="...", concerns=[...], confidence=0.85)
deliberation_opinion(session_id, expert="security", ...)
deliberation_result(session_id)
```

Experts: `architect`, `security`, `database`, `api`, `performance`, `testing`, `devops`, `critic`

---

## Resume workflow

This repo maintains a LaTeX resume. Several files exist with distinct, non-overlapping roles — don't conflate them:

- `resume.tex` — the main resume version, our **work zone**. This is the draft we actively edit and tailor.
- `base_resume.tex` — an archive containing every entry that has ever existed across all versions. Very bloated. Kept only as a point of reference (e.g. to pull back an old bullet); never built or edited as the active resume.
- `print_resume.tex` — a copy of `resume.tex`'s content, but with header links kept hardcoded (not shortened/dynamic), used specifically for printing on paper at career fairs.
- `build_resume.sh [file]` — builds a `.tex` file into a `.pdf` (defaults to `resume.tex`; pass a name without extension, e.g. `print_resume`, to build a different file).
- `apply_changes_to_resume.sh` — copies `resume.pdf` over `Mohamed_Abdelrahman_Resume.pdf`, the main tracked PDF. Run this as the final step once `resume.pdf` is finalized, to publish the change.
- `pagecount.sh <pdf>` — reports whether a PDF is 1 page or more. The resume must stay under 1 page: shorten text rather than letting content spill over. Line wrap-arounds that leave incomplete/orphaned trailing lines are the main enemy of fitting on 1 page — watch for those first when trimming.
- `generate_tailored_resume_copy.sh CompanyName [spring|fall]` — generates a tailored resume PDF for a specific job requisition based on the current `resume.tex`, saved to `custom_resumes/CompanyName/Mohamed_Abdelrahman_Resume.pdf`. Always pass the correct company name (and grad term, if relevant to the posting) so the output lands in the right directory.
- `listings/` — job postings saved as `.html`/`.mhtml` files for you to parse and use when tailoring `resume.tex` to a specific role.

### Tailoring workflow for a job listing

1. Parse the relevant file in `listings/` to understand the role.
2. Edit `resume.tex` to tailor content (wording, emphasis, bullet selection) to that job.
3. Build and verify page count stays at 1 (`build_resume.sh`, `pagecount.sh`) — reword/shorten rather than letting it overflow.
4. Run `generate_tailored_resume_copy.sh CompanyName [spring|fall]` to produce and save the company-specific copy.
5. **Always use `generate_tailored_resume_copy.sh` to persist a tailored copy for each job position.** If we skip it, the tailoring changes are lost since `resume.tex` is meant to remain a rough, general-purpose work-bench draft rather than permanently drifting toward one specific job.
