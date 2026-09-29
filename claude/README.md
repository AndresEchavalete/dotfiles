# Claude Code package

Portable Claude Code config. `.claude/` mirrors `$HOME`. Corporate data and
secrets are never tracked. Install differs by host **on purpose**:

## Home (clean host) — Stow

```bash
cd ~/dotfiles && stow claude
```

Symlinks `.claude/*` into `~/.claude/`. If Stow reports a conflict, move the
existing real file aside first (see the repo README). **Never** use `stow --adopt`
here — it would pull the live (secret-bearing) file into the repo.

## Office (corporate host) — copy script, no symlinks

```bash
cd ~/dotfiles/claude
./sync.sh apply      # repo   -> ~/.claude   (bring config down)
./sync.sh capture    # ~/.claude -> repo     (push changes up: scrub + leak gate)
```

`capture` copies only an allowlist, strips OTEL/telemetry from `settings.json`,
templatizes `$HOME`, and aborts if it detects `zafirus`/tokens. Review `git diff`
before committing.

## Secrets & telemetry (both hosts)

OTEL telemetry is **not** in the tracked `settings.json`. Put the exports in
`~/.bashrc.local` (gitignored) per host:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_EXPORTER_OTLP_ENDPOINT="https://otel.<your-host>"
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
```

## Leak guard (recommended)

```bash
ln -sf ../../claude/git-pre-commit-guard.sh .git/hooks/pre-commit
```

## Plugins & skills

Not vendored — reinstall via `.claude/manifest/plugins.json` and the commands in
`.claude/manifest/skills.md`. Corporate skills (`migrate-ecosystem`, `progal-soap`)
stay only on the office host.
