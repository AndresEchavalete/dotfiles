#!/usr/bin/env bash
# Hook: Git Guard
# Evento: PreToolUse (matcher: Bash)
# Bloquea operaciones git destructivas o de commit/push.

set -euo pipefail

INPUT=$(cat)

COMMAND=$(echo "${INPUT}" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

[ -z "${COMMAND}" ] && exit 0

BLOCKED=""

# git commit (cualquier forma)
echo "${COMMAND}" | grep -qE '\bgit\s+commit\b' && BLOCKED="git commit"

# git push (cualquier forma)
[ -z "${BLOCKED}" ] && echo "${COMMAND}" | grep -qE '\bgit\s+push\b' && BLOCKED="git push"

# git add masivo: -A / --all / -u / --update (staging masivo)
[ -z "${BLOCKED}" ] && echo "${COMMAND}" | grep -qE '\bgit\s+add\s+(-A\b|--all\b|-u\b|--update\b)' && BLOCKED="git add (masivo)"

# git add . (solo el punto aislado, NO ./archivo ni .env)
[ -z "${BLOCKED}" ] && echo "${COMMAND}" | grep -qE '\bgit\s+add\s+\.(\s|$|[;&|])' && BLOCKED="git add ."

# git reset --hard (descarta cambios irrecuperablemente)
[ -z "${BLOCKED}" ] && echo "${COMMAND}" | grep -qE '\bgit\s+reset\s+--hard\b' && BLOCKED="git reset --hard"

# git checkout . / git restore . (solo el punto aislado, NO ./archivo)
# Cubre tambien variantes con -- (ej: git checkout -- . / git restore -- .)
[ -z "${BLOCKED}" ] && echo "${COMMAND}" | grep -qE '\bgit\s+(checkout|restore)\s+(--\s+)?\.(\s|$|[;&|])' && BLOCKED="git checkout/restore ."

if [ -n "${BLOCKED}" ]; then
    jq -n --arg reason "BLOQUEADO: ${BLOCKED} esta prohibido. El usuario gestiona git manualmente." \
        '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
    exit 0
fi

exit 0
