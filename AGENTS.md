# AGENTS.md — discipline rules for this repo

This file is the **single source of truth** for any AI agent (or human) editing **this dotfiles repo**. Follow these rules exactly. The _why_ behind them lives in [`docs/adr/`](docs/adr/); this file is the _what_.

> Not to be confused with `agents/AGENTS.md`, which is a **template** that stows to `~/AGENTS.md` (personal, cross-project rules). This root file governs work _inside this repository only_.

## Hard rules

1. **Real names, no templating.** Dotfiles are stored under their REAL names (`.zshrc`, `.gitconfig`), never chezmoi-style `dot_` mangling and never Go template syntax. Content stays tool-agnostic (ADR-0001).

2. **Per-machine / per-OS differences go in SOURCED shell behind guards** — an `if [[ -d ... ]]`, an `$OSTYPE` check, or an untracked override file — never in templates. If a value differs by machine, it belongs in guarded shell or in `local.zsh`, not baked into a tracked config.

3. **Orchestration stays in plain scripts.** Setup logic lives in `Brewfile`, `os/macos/*.sh`, and `install.sh` (+ `lib/*.sh`). Do not introduce a templating DSL or a declarative manager to do orchestration.

4. **Secrets ONLY via untracked `secrets.zsh`; machine overrides via untracked `local.zsh`.** Never commit either. Never hardcode a secret in a tracked file. `secrets.zsh` holds values (supports `op read` or plaintext); `local.zsh` holds non-secret machine overrides and is sourced LAST so it wins (ADR-0005). Both are already in `.gitignore` — keep them there.

5. **macOS-only config is isolated** under `os/macos/` (orchestration: `defaults.sh`, `stow-post.sh`) and `sh/os/macos.sh` (shell helpers, sourced behind an `$OSTYPE` guard). Leave room for a future `sh/os/linux.sh` to drop in alongside — do not hardwire macOS assumptions into shared files.

6. **PATH is assembled EXACTLY ONCE**, in `zsh/.zshenv`, via `typeset -U path` (unique entries, first wins). Nothing else may mutate `PATH` — the only permitted exception is `.zprofile` _appending_ guarded, machine-specific dirs (e.g. the Android SDK block). Do not add `PATH=` or `export PATH=...` lines anywhere else.

7. **Every ported `sh/` function keeps `namespace::func` naming + a docblock comment**, and should gain a **bats test**. Example:

   ```bash
   ###############################################################################
   # One-line description. @params ... @output ...
   ###############################################################################
   git::clone_cd() { ...; }
   ```

8. **Lint gates must pass — run `mise run check`.** All gates are `mise` tasks (defined in the repo-root `mise.toml`), so local == CI == the lefthook pre-commit hook. Shell must pass `shellcheck` (config in `.shellcheckrc`, bash semantics) and `shfmt`; zsh files must pass `zsh -n`; TOML `taplo`; YAML `yamlfmt`; markdown is formatted by `dprint` (unwraps prose, aligns tables) and linted by `markdownlint-cli2`; workflows `actionlint`, whitespace `editorconfig-checker`. `mise run fmt` auto-formats; `mise run lint` is the read-only gate; `mise run
 test` runs the bats suite under `test/`. Bootstrap once with `mise install &&
 mise run setup`. See [ADR-0006](docs/adr/0006-dev-tooling-mise-tasks-lefthook.md).

9. **stow package layout: a top-level dir mirroring `$HOME`.** A package directory contains the target's home-relative tree. Examples:
   - `zsh/.zshenv` → `~/.zshenv`
   - `zsh/.config/zsh/...` → `~/.config/zsh/...`
   - `agents/.claude/settings.json` → `~/.claude/settings.json`
   - `agents/AGENTS.md` → `~/AGENTS.md`

## Editing constraints

- **Only create/edit what the task asks for.** Do not "drive-by" refactor `install.sh`, `lib/**`, `zsh/**`, etc. unless that is the task.
- **Never run `install.sh` against the real `$HOME`.** For stow verification, target a throwaway home: `T=$(mktemp -d); stow --target="$T" -n ...`.
- **Never stow the `agents/` package onto the real `$HOME`** — the machine has a live `~/.claude/` with real content. Dry-run into a `mktemp -d` only.
- Do not `git commit`/`push` unless explicitly asked.
- `.editorconfig` rules: 2-space indent, LF, UTF-8, final newline. Markdown keeps trailing whitespace (hard line breaks); do not trim it.

## Comments

Comment the **why**, not the **what** — a comment earns its place only by adding intent, rationale, or a constraint the code can't express. Prefer self-documenting code (naming, structure) over a comment that explains around it.

- **Don't restate the code.** If the comment paraphrases what the line already says, delete it.
- **Assert only what's true at this location.** Don't narrate another file's behavior — nothing checks that description, so it goes stale. Let each file document itself; point (`see X`) rather than paraphrase.
- **Prefer a general pointer to the source of truth** over a copy of its contents that can drift.
- **Deletion test.** Remove the comment and ask what a competent reader loses. Nothing → leave it removed.
- **Wrap at 100 columns**, not the default ~80 (matches `.editorconfig` `max_line_length`).

## Presets & modules (the install model)

`install.sh` resolves a **preset** into a set of **modules** through one code path shared by the interactive `gum` TUI and the non-interactive flags ([ADR-0007](docs/adr/0007-presets-and-modules.md)). Composition is `saved selection or preset defaults ∪ --with − --without`, then `depends_on` expansion. GUI is orthogonal (`--gui` / `--no-gui`).

- **Presets**: `dev`, `headless`. `headless` defaults to no GUI (skips casks/fonts and the macOS phases).
- **Modules**: technology-shaped units (`core`, `git`, `js`, `jvm`, `aws`, `gcp`, `docker`, …). Each may map to stow packages + optional `brew/Brewfile.<module>` + optional `mise/<module>.toml` (and later other hooks).
- **Persistence**: `~/.config/dotfiles/selection`. `--fresh` ignores it; `--no-save` skips writing.

Definitions live in `lib/modules.sh`. To add a module, extend `MODULES_ALL` and the `*_for_module` / `depends_on` / `category` mappings — it then appears in both the TUI and the flag parser.

## Repo layout

```text
install.sh            # single entry point; phases: preflight stow brew mise macos app post
lib/                  # log.sh, stow.sh, modules.sh (sourced by install.sh)
Brewfile              # base formulae; brew/Brewfile.<module>, brew/Brewfile.casks
brew/                 # per-module Brewfile fragments + casks
mise/                 # config.toml (base) + <module>.toml fragments
zsh/                  # stow package → ~/.zshenv and ~/.config/zsh/**
  .zshenv             # PATH assembled ONCE here (typeset -U path)
  .config/zsh/.zprofile   # login shells; guarded machine-specific PATH appends
  .config/zsh/sh/     # namespace::func shell library (tested via bats)
  .config/zsh/sh/os/  # macos.sh (+ future linux.sh), sourced behind $OSTYPE guard
git/ bat/ direnv/ tmux/ ghostty/ starship/ nvim/ bin/   # more stow packages
agents/               # stow package → ~/.claude/** and ~/AGENTS.md (templates)
os/macos/             # macOS orchestration (defaults.sh, stow-post.sh)
test/                 # bats + submodule helpers (bats-support/assert/file)
docs/adr/             # architecture decision records (the "why")
secrets.zsh local.zsh # UNTRACKED (gitignored) — never commit
```

## Before you finish

- `mise run check` passes (fmt-check + all linters + bats). Run `mise run fmt` first to auto-format. The lefthook pre-commit hook runs the same gates.
- New/changed `sh/` functions have a docblock and a bats test.
- No new `PATH` mutation outside `.zshenv` / guarded `.zprofile`.
- No secrets or machine-specific values committed.
