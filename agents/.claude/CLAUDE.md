# Global agent preferences

<!--
  Stows to ~/.claude/CLAUDE.md. User-global (cross-project) instructions for
  Claude Code. This is a TEMPLATE — customize it to taste. Keep it short;
  project-specific rules belong in each project's own AGENTS.md / CLAUDE.md.
-->

- Be concise. Lead with the answer, then the reasoning if needed.
- Prefer editing existing files over creating new ones. Do not create docs or READMEs unless asked.
- Match the surrounding code's style and conventions; read before you write.
- Never commit or push unless explicitly asked. Never commit secrets.
- When a repo has an `AGENTS.md`, treat it as authoritative and follow it.
- Ask before destructive or irreversible actions (deletes, force-push, resets).
- No emojis in code, commits, or file content unless requested.
- Prefer `--json`/`-o json` + `jq` over parsing CLI table output; avoid interactive/TUI tools (`lazygit`, `btop`, `fzf`) and disable pagers (`--no-pager`, `| cat`) in scripts.
- For structural code search/refactors prefer `ast-grep` over plain regex; use `difftastic` to review diffs with heavy reformatting noise.
- Run the project's formatter once before iterating on linter fixes.
