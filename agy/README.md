# agy package — Antigravity / Gemini CLI config

Portable config for `agy` (the Antigravity/Gemini agent CLI). Mirrors `$HOME`.
This is a **personal** account, so it uses plain Stow on every host (like `nvim`) —
no corporate copy/scrub machinery. Personal secrets and runtime state are still
kept out of git.

## Versioned

| Path | What |
|------|------|
| `.gemini/GEMINI.md` | global agent instructions |
| `.gemini/settings.json` | agy settings (MCP servers) |
| `.gemini/antigravity-cli/settings.json` | Antigravity CLI settings |
| `.gemini/antigravity-cli/keybindings.json` | keybindings |
| `.config/antigravity/statusline.sh` | statusline script |
| `.agents/.skill-lock.json` | agy skill lock manifest |

## Never tracked (personal secrets / state)

`.gemini/antigravity-cli/antigravity-oauth-token`, `.gemini/config/` (config.json,
`mcp_config.json`, `projects/`), all Antigravity CLI runtime state (db, history,
conversations, cache, brain, knowledge, logs, installation_id), and the
installer-managed `.agents/skills/` store. All excluded via `.gitignore`.

## Install (all hosts)

```bash
cd ~/dotfiles && stow agy
```

Move any conflicting real file aside first; never use `stow --adopt` (it would pull
the live oauth-token/state into the repo). Skills are reproduced by `agy` from
`.agents/.skill-lock.json`, not vendored.
