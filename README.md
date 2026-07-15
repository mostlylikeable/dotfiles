# dotfiles

Turnkey macOS (Apple Silicon) developer environment. One command takes a fresh Mac — or a fresh user profile — to a fully configured modern shell and toolchain.

Managed with [GNU stow](https://www.gnu.org/software/stow/) (symlink farm) driven by a thin, idempotent `install.sh`. Configs live under their real names so the content stays tool-agnostic; see [`docs/adr/`](docs/adr/) for the decisions behind that (and why not chezmoi/Nix).

## Quick start

```sh
git clone https://github.com/mostlylikeable/dotfiles ~/dev/me/dotfiles
cd ~/dev/me/dotfiles
./install.sh                 # interactive: pick a preset + modules
```

Non-interactive:

```sh
./install.sh --preset dev --yes
./install.sh --preset headless --yes      # servers/containers: no GUI apps
./install.sh --with aws,gcp,docker        # additive on top of saved selection
./install.sh --fresh --preset dev --yes   # ignore saved selection
```

Preview without touching anything:

```sh
./install.sh --dry-run --non-interactive --preset dev
```

After it finishes, restart your shell: `exec zsh`.

## Presets & modules

A **preset** is a named default set of **modules** (plus a default GUI flag). A **module** is a technology-shaped unit that may contribute stow packages, a Brewfile fragment, a mise manifest, and later other install hooks. See [ADR-0007](docs/adr/0007-presets-and-modules.md).

| Preset     | Default modules | GUI? |
| ---------- | --------------- | ---- |
| `dev`      | core, git, js   | yes  |
| `headless` | core, git       | no   |

| Module        | Intent                                             | Contents (source of truth)                                                                    |
| ------------- | -------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `core`        | Modern CLI baseline                                | [`Brewfile.core`](brew/Brewfile.core), stow: zsh/starship/bat/direnv/tmux/ghostty/bin         |
| `git`         | Git ergonomics                                     | [`Brewfile.git`](brew/Brewfile.git), stow: git                                                |
| `js`          | Node.js                                            | [`mise/js.toml`](mise/js.toml)                                                                |
| `jvm`         | JDK                                                | [`mise/jvm.toml`](mise/jvm.toml)                                                              |
| `python`      | CPython + build deps                               | [`mise/python.toml`](mise/python.toml), [`Brewfile.python`](brew/Brewfile.python)             |
| `ruby`        | MRI + build deps                                   | [`mise/ruby.toml`](mise/ruby.toml), [`Brewfile.ruby`](brew/Brewfile.ruby)                     |
| `go` / `rust` | Language toolchains                                | [`mise/go.toml`](mise/go.toml), [`mise/rust.toml`](mise/rust.toml)                            |
| `aws`         | AWS CLI                                            | [`Brewfile.aws`](brew/Brewfile.aws)                                                           |
| `gcp`         | Google Cloud CLI                                   | [`Brewfile.gcp`](brew/Brewfile.gcp)                                                           |
| `terraform`   | Terraform                                          | [`Brewfile.terraform`](brew/Brewfile.terraform)                                               |
| `k8s`         | kubectl / helm / k9s                               | [`Brewfile.k8s`](brew/Brewfile.k8s)                                                           |
| `docker`      | OrbStack (Docker-compatible)                       | [`Brewfile.docker`](brew/Brewfile.docker)                                                     |
| `mobile-rn`   | React Native native toolchain (depends on js, jvm) | [`Brewfile.mobile-rn`](brew/Brewfile.mobile-rn), [`mise/mobile-rn.toml`](mise/mobile-rn.toml) |
| `nvim`        | Neovim config                                      | stow: nvim                                                                                    |
| `agents`      | `~/AGENTS.md` + `~/.claude` templates (opt-in)     | stow: agents                                                                                  |

Selection is persisted to `~/.config/dotfiles/selection`. Re-runs seed from that file unless `--fresh`. Use `--no-save` to skip writing. Dependencies are auto-enabled (`mobile-rn` → `js` + `jvm`).

Flags: `--preset` (alias `--profile`), `--modules`, `--with`, `--without`, `--gui` / `--no-gui`, `--fresh`, `--no-save`, `--list`, `--yes` / `--non-interactive`, `--dry-run`, `--only <phase>`, `--skip <phase>`, `--adopt`. Phases: `preflight stow brew mise macos app post`.

## Layout

```text
install.sh              single entrypoint (gum TUI + flags, one code path)
Brewfile                minimal base packages
brew/Brewfile.<module>  per-module Homebrew fragments (+ Brewfile.casks)
mise/                   base + per-module runtime manifests
lib/                    install-time helpers (log, stow, modules) — not stowed
os/macos/               defaults.sh, stow-post.sh (VS Code/Cursor/iTerm2), app config
scripts/                doctor.sh (health check), uninstall.sh
docs/adr/               architecture decision records
test/                   bats-core tests
AGENTS.md               repo discipline rules (read this before editing)

STOW PACKAGES (each mirrors $HOME):
zsh/ starship/ git/ bat/ direnv/ tmux/ ghostty/ bin/ nvim/ agents/
```

## Secrets & machine-local overrides

Two untracked files, both sourced last by `.zshrc` (see [ADR-0005](docs/adr/0005-secrets-and-local-overrides.md)):

- `~/.config/zsh/secrets.zsh` — secret values. Supports 1Password (`export TOKEN="$(op read op://vault/item/field)"`) or plaintext.
- `~/.config/zsh/local.zsh` — non-secret machine overrides (wins last). E.g. `export DOTFILES_SAFE_RM=1` to alias `rm` → trash.

Both are gitignored. Never commit secrets.

Git identity is likewise kept out of the repo: copy `git/.config/git/identity.example` → `~/.config/git/identity`, and `git/.gitconfig-work.example` → `~/.gitconfig-work` (auto-included for repos under `~/dev/work/`).

## Health check & uninstall

```sh
./scripts/doctor.sh                        # read-only; verifies links, tools, PATH
./scripts/uninstall.sh                     # remove symlinks (stow -D)
./scripts/uninstall.sh --restore-latest    # also restore the newest backup snapshot
```

Conflicting real files found during install are moved to `~/.dotfiles-backup/<timestamp>/` with a `manifest.tsv` so they can be restored.

## Development

Tooling is driven by [`mise`](https://mise.jdx.dev) tasks (see [ADR-0006](docs/adr/0006-dev-tooling-mise-tasks-lefthook.md)). The same tasks run locally, in the git hooks, and in CI — no drift.

```sh
mise install && mise run setup   # one-time: install pinned tools + git hooks

mise run fmt      # auto-format shell (shfmt), TOML (taplo), markdown (dprint)
mise run lint     # read-only gate: shellcheck, zsh -n, markdownlint, actionlint, editorconfig, …
mise run test     # bats suite (vendored runner)
mise run check    # lint + test (what CI enforces)
```

The lefthook pre-commit hook formats staged files and lints; pre-push runs the tests. See [`AGENTS.md`](AGENTS.md) for the conventions every change must follow.
