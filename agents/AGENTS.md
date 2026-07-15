# AGENTS.md — personal, cross-project conventions

<!--
  Stows to ~/AGENTS.md. These are MY defaults for any AI agent working in ANY
  project on this machine. A project's own AGENTS.md overrides anything here.
  This is a TEMPLATE — customize it. (Distinct from this dotfiles repo's own
  root AGENTS.md, which governs edits to the dotfiles repo itself.)
-->

## Working style

- Understand before changing: read the relevant code and tests first.
- Make the smallest change that fully solves the task. No drive-by refactors.
- Prefer editing existing files; do not add new files unless necessary.

## Safety

- Never commit or push without an explicit ask. Never commit secrets or machine-local values.
- Secrets come from the environment or a password manager (1Password `op`), never hardcoded.
- Confirm before destructive/irreversible actions.

## Quality

- Follow each project's existing style, lint, and test conventions.
- Add or update tests when changing behavior.
- Keep functions small and named clearly; document non-obvious decisions.

## Tool preferences

- Prefer `--json`/`-o json` (+ `jq`) over parsing formatted CLI output — e.g. `gh ... --json fields --jq '...'`, `kubectl get -o json`, `docker inspect`. More reliable to parse and usually cheaper than scraping a table.
- Avoid interactive/TUI tools in scripts (`lazygit`, `btop`, `fzf`, `htop`) — they can hang a non-interactive shell waiting for input. Use the flag-driven, non-interactive equivalent instead (`git status`/`git log`, `ps aux`, etc.).
- Disable pagers for scripted output (`--no-pager`, `| cat`, `GIT_PAGER=cat`) so `git`/`gh`/`man` never block waiting for a keypress.
- For structural code search or multi-file refactors, prefer `ast-grep`/ `comby` over plain regex (`grep`/`rg`) when the match should respect syntax (e.g. "calls to `foo()`") rather than just text.
- Use `difftastic` (`difft`) to review diffs with heavy reformatting/rename noise; plain `git diff` is fine for small, surgical changes.
- Run the project's formatter in one pass (e.g. `shfmt`, `taplo`) before iterating on linter fixes one at a time.

## Communication

- Concise, direct, answer-first. No emojis unless asked.
- State assumptions; flag anything uncertain rather than guessing silently.
