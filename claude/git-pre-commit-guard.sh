#!/usr/bin/env bash
# Defense-in-depth leak guard for the dotfiles repo (both hosts).
# Install once:  ln -sf ../../claude/git-pre-commit-guard.sh .git/hooks/pre-commit
# Blocks a commit if staged additions contain corporate endpoints / secrets.
if git diff --cached -U0 | rg '^\+' 2>/dev/null \
   | rg 'zafirus|otel\.[a-z]|-----BEGIN|ghp_[A-Za-z0-9]|sk-ant-|xox[baprs]-' 2>/dev/null; then
  echo "❌ pre-commit: possible corporate/secret leak in staged changes — aborting."
  echo "   Review the lines above; unstage or scrub them, then commit again."
  exit 1
fi
exit 0
