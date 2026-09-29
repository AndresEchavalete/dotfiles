#!/usr/bin/env bash
# Office (corporate host) sync — COPY only, never symlink. Stow is for the clean host.
#   capture : ~/.claude  -> repo   (allowlist + scrub OTEL/telemetry + leak gate)
#   apply   : repo       -> ~/.claude (real files; OTEL comes from ~/.bashrc.local)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.claude" && pwd)"
LIVE="$HOME/.claude"

# Only these paths ever cross. State/secrets/corporate skills are never listed.
FILES=(
  settings.json statusline-command.sh CLAUDE.md RTK.md
  output-styles/gentleman.md themes/gentleman.json themes/gentleman-cute.json
  hooks/git-guard.sh hooks/rtk-rewrite.sh hooks/herdr-agent-state.sh
  mcp/context7.json mcp/engram.json
)

leak_scan() {
  if rg -n 'zafirus|otel\.|-----BEGIN|ghp_[A-Za-z0-9]|sk-ant-|xox[baprs]-' "$1" 2>/dev/null; then
    echo "❌ LEAK detected in repo copy — aborting, nothing committed."; exit 1
  fi
}

case "${1:-}" in
  capture)
    for r in "${FILES[@]}"; do
      [ -f "$LIVE/$r" ] || { echo "skip (missing): $r"; continue; }
      mkdir -p "$REPO/$(dirname "$r")"; cp "$LIVE/$r" "$REPO/$r"; echo "captured $r"
    done
    # Strip telemetry from the tracked settings (OTEL lives in ~/.bashrc.local).
    jq 'if .env then .env |= with_entries(select(.key | test("^OTEL_|^CLAUDE_CODE_ENABLE_TELEMETRY$") | not)) else . end' \
       "$REPO/settings.json" > "$REPO/settings.json.t" && mv "$REPO/settings.json.t" "$REPO/settings.json"
    # Templatize the real home path so the repo copy stays portable.
    sed -i "s|$HOME|\$HOME|g" "$REPO/settings.json" "$REPO/statusline-command.sh"
    sed -i -E "s|bash '(\\\$HOME[^']*)'|bash \"\1\"|g" "$REPO/settings.json"   # keep $HOME expandable
    sed -i "s|$HOME|\${HOME}|g" "$REPO/mcp/engram.json"                        # MCP uses ${VAR}
    leak_scan "$REPO"
    echo "✅ capture OK — review 'git diff' before committing."
    ;;
  apply)
    for r in "${FILES[@]}"; do
      [ -f "$REPO/$r" ] || continue
      mkdir -p "$LIVE/$(dirname "$r")"; cp "$REPO/$r" "$LIVE/$r"; echo "applied $r"
    done
    echo "✅ apply OK — ensure OTEL_* exports live in ~/.bashrc.local on this host."
    ;;
  *)
    echo "usage: $0 {capture|apply}"; exit 2 ;;
esac
