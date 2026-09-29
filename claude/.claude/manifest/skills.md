# Skills inventory & provenance

Skills are **not** vendored into this repo. They are managed by their installers
and reproduced by `bootstrap.sh` via `manifest/plugins.json` plus the commands
below. Copying skill directories would freeze them at a stale version.

## By origin

| Origin | Reproduced by | Notes |
|--------|---------------|-------|
| Plugins | `manifest/plugins.json` → `claude plugin install` | caveman, context7, engram, frontend-design, superpowers |
| gstack suite | gstack installer / `/gstack-upgrade` | qa, browse, cso, ship, review, design-*, plan-*, etc. |
| gentle-ai / SDD | gentle-ai installer | `sdd-*`, `gentle-sdd-*`, `_shared/`, `synced/`, `agents/`, `commands/` |
| External (`~/.agents`) | its own installer | `archify`, `archify-review` (symlinks) |

## Excluded on purpose (corporate — never leave the host)

- `migrate-ecosystem` — MailAmericas ecosystem DB migrations.
- `progal-soap` — Progal SOAP integration.

These stay only in `~/.claude/skills/` on the corporate host.

## Plugin reinstall

```bash
claude plugin marketplace add JuliusBrussee/caveman
claude plugin marketplace add Gentleman-Programming/engram
claude plugin install caveman@caveman
claude plugin install engram@engram
claude plugin install superpowers@claude-plugins-official
claude plugin install context7@claude-plugins-official
claude plugin install frontend-design@claude-plugins-official
```
