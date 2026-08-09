# .clinerules

## Session Recovery
- On every session start, first read `SESSION_MEMORY.md` (at project root) to recover full context of the current phase, completed steps, architecture decisions, bug fixes, and next steps.
- After reading the memory file, verify current state with `git log --oneline -5` and `git status`.
- If continuing a work-in-progress, check for any uncommitted changes and understand what was being done before the session ended.

## Environment
- Shell is Windows PowerShell. Use `;` to chain commands, not `&&`.
- Working directory persists across chained commands within a single tool call — do not repeat `cd` for every command in the same chain.
- When investigating a task, prefer the file paths already named in the relevant plan/spec doc over discovering structure via directory listings or grep. Only search/list directories when the plan doesn't specify a path or the file may not exist yet.
- When passing Windows paths as arguments (e.g. `git -C <path>`), preserve backslashes exactly. Prefer `cd 'C:\xampp\htdocs\stock-count-app'; git status` over `git -C` with an inline path — `-C` path escaping has been unreliable in this environment.

## Token Efficiency Rules

### Context & Caching
- Do not modify the system prompt, mode, or configuration mid-task.
- Only read files directly relevant to the current task. Do not scan the full repository unless explicitly instructed.
- When reading files, prefer targeted line ranges over full-file reads when the relevant section is known or can be reasonably scoped.
- When continuing into Act mode after a Plan-mode status check in the same session, treat that check's findings as current. Do not re-run discovery commands (git status, git log, directory listings) already completed in Plan mode unless something may have changed since.

### Output
- Default to terse output. Do not explain actions before taking them unless asked.
- When editing existing code, output a diff/patch of changed lines only, not the full file, unless the file is new.
- Do not restate instructions back before acting.
- Do not add a summary after completing a task unless it was complex or requested.

### Scope discipline
- Only modify what was explicitly requested. Do not refactor, rename, or reformat adjacent code.
- If a task requires touching files outside the stated scope, stop and ask first.
- Follow existing project conventions exactly as found in the codebase.

### Effort matching
- For simple, well-specified edits, execute directly without extended exploration.
- Reserve deep multi-file analysis for genuinely ambiguous or architectural tasks.

### Line Endings & Editing
- **CRLF can block automated edits** that rely on exact byte matching. If an edit tool fails with a `CRLF`/`LF` mismatch:
  1. **Convert the file to LF (Unix) temporarily** using PowerShell:  
     `(Get-Content -Raw -Path 'file.dart') -replace "`r`n","`n" | Set-Content -NoNewline -Path 'file.dart'`
  2. Perform the edit using normal tools.
  3. **Restore the original line ending style afterwards** if the project prefers CRLF (check `.gitattributes` or existing file endings).  
     To re-add CRLF:  
     `(Get-Content -Raw -Path 'file.dart') -replace "`n","`r`n" | Set-Content -NoNewline -Path 'file.dart'`
- **Alternative**: Use PowerShell’s text replacement for simple changes to bypass the string-matching limitation entirely:  
  `(Get-Content -Path 'file.dart') -replace 'UnitType.currency','UnitType.monetary' | Set-Content -Path 'file.dart'`  
  (This works regardless of line endings but watch for unwanted regex behavior — escape regex characters if needed.)
- When a file’s line endings are unknown, check before editing with:  
  `(Get-Content -Raw -Path 'file.dart') -match "`r`n"` → `True` means CRLF.

## Plan Mode Specific
- Plan mode is read-only by design (no file writes, no destructive commands). Investigation commands (git status/log, ls, read-only file reads) are safe to run without per-command narration.
- When asked for a status check against a plan doc, structure the answer as: completed steps, in-progress step (with % or specific sub-state), deviations from plan, blockers/assumptions, next step. Do not pad with exploratory narration in the final answer — just the findings.

- Use native PowerShell cmdlets only (Get-ChildItem, not `ls`;
  no piping to `head`, `grep`, etc. unless confirmed available).
  Do not assume Unix-style aliases work.
- Verify a file/directory exists before reading from it. Do not
  guess paths — list the directory first if uncertain.
- Stay strictly within the scope of what was asked. Do not
  investigate tangential issues (encoding, byte-level inspection,
  etc.) unless they directly block completing the current task.
## Release, Build & Deployment Rules (MANDATORY)

Applies to all build / deploy / backup / versioning work. Procedures live in DEPLOYMENTS.md, CHANGELOG.md, scripts\backup-live-build.ps1.

### Versioning
- Keep `pubspec.yaml` version as semver `major.minor.patch+build` (currently 1.7.0+0).
- Bump the build number on every build intended for prod; bump patch/minor for fixes/features.
- Commit the version bump BEFORE building, and tag it: `git tag v1.7.0+0` (push the tag too).

### Building
- Build once, archive immediately: after `flutter build web --release`, zip `build/web` into the gitignored `releases/` folder. `flutter clean` is safe ONLY after archiving.
- `build/web/version.json` is the build fingerprint - compare it against the deployed URL to confirm what is live.

### Deploying
- NEVER run bare `firebase deploy`. Always: `npx firebase-tools@15.25.1 deploy --only hosting --project <id> --message "vX.Y.Z+N <short-hash>"`.
- Staging project: `stock-count-app-staging` (https://stock-count-app-staging.web.app). Prod: `stock-count-app-c381c` (https://stock-count-app-c381c.web.app).
- Flow: merge to main -> deploy staging -> test -> tag + deploy prod.

### Backups & rollback
- Run `scripts\backup-live-build.ps1` BEFORE every prod deploy (downloads live build to timestamped folder, double-fetch SHA-256 verifies, zips, keeps last 5).
- Log every deployment in `DEPLOYMENTS.md` (date, env, version, commit, URL, verified).
- Rollback = Firebase console release history, or restore the backup zip into `build/web` and re-deploy.

### Git hygiene
- Push to origin after every merge. Do not let local main grow far ahead of origin (a 19-commit backlog once accumulated).
- **NEVER merge to `main`** when implementing a feature or fix. Always work on a feature branch (e.g., `feat/...`, `fix/...`). Commit there, push the branch, and let the user review, sanity-test, and merge when ready. This applies to ALL implementation work — the user is the final gatekeeper for merging.

