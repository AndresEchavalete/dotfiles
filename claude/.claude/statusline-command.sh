#!/bin/bash
input=$(cat)

# --- Caveman badge (orange, only shown when active) ---
# Resolve caveman hook path dynamically (version hash is not portable across hosts).
caveman_hook=$(ls "$HOME"/.claude/plugins/cache/caveman/caveman/*/hooks/caveman-statusline.sh 2>/dev/null | head -1)
caveman_badge=""
[ -n "$caveman_hook" ] && caveman_badge=$(bash "$caveman_hook" <<< "$input" 2>/dev/null)

# --- Model display name ---
model=$(echo "$input" | jq -r '.model.display_name // .model.id // empty')

# --- Git branch (from cwd field) ---
cwd=$(echo "$input" | jq -r '.cwd // empty')
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# --- Context usage ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Active subagents (from SubagentStart/SubagentStop hooks) ---
session_id=$(echo "$input" | jq -r '.session_id // empty')
agent_log="$HOME/.claude/agent-activity.jsonl"
active_agents=0
if [ -f "$agent_log" ]; then
  lines=$(wc -l < "$agent_log" 2>/dev/null || echo 0)
  if [ "$lines" -gt 3000 ]; then
    tail -n 1000 "$agent_log" > "$agent_log.tmp" 2>/dev/null && mv "$agent_log.tmp" "$agent_log"
  fi
  active_agents=$(jq -s --arg sid "$session_id" '
    map(select(.session_id == $sid)) |
    group_by(.agent_id) |
    map(select((map(select(.event=="start")) | length) > (map(select(.event=="stop")) | length))) |
    length
  ' "$agent_log" 2>/dev/null)
  [ -z "$active_agents" ] && active_agents=0
fi

# --- Build output ---
parts=()

# Caveman badge (no extra label — it already includes brackets)
if [ -n "$caveman_badge" ]; then
  parts+=("$caveman_badge")
fi

# Model (cyan)
if [ -n "$model" ]; then
  parts+=("$(printf '\033[01;36m%s\033[0m' "$model")")
fi

# Git branch (yellow)
if [ -n "$git_branch" ]; then
  parts+=("$(printf '\033[01;33m\uE0A0 %s\033[0m' "$git_branch")")
fi

# Active subagents badge (magenta, only shown when > 0)
if [ "$active_agents" -gt 0 ] 2>/dev/null; then
  parts+=("$(printf '\033[01;35m\U0001F916 %s\033[0m' "$active_agents")")
fi

# user@host:dir (classic green/blue, only last directory name)
dir_name=$(basename "$cwd")
user_host_path="$(printf '\033[01;32m%s@%s\033[0m:\033[01;34m%s\033[0m' "$(whoami)" "$(hostname -s)" "$dir_name")"
parts+=("$user_host_path")

# Context used % — ASCII progress bar (always shown; placeholder before first API call)
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 75 ]; then
    ctx_color='\033[01;31m'        # bold red
  elif [ "$used_int" -ge 50 ]; then
    ctx_color='\033[01;38;5;208m'  # bold orange (256-color)
  else
    ctx_color='\033[01;33m'        # bold yellow
  fi
  filled=$(( used_int * 10 / 100 ))
  empty=$(( 10 - filled ))
  bar=""
  for ((i=0; i<filled; i++)); do bar="${bar}█"; done
  for ((i=0; i<empty;  i++)); do bar="${bar}░"; done
  parts+=("$(printf "${ctx_color}[%s] %d%%\033[0m" "$bar" "$used_int")")
else
  parts+=("$(printf '\033[02;37m[░░░░░░░░░░] -\033[0m')")
fi

# Compaction heuristic indicator (rough proxy only — not a reliable signal).
# A very high cache_read_input_tokens relative to input_tokens (or absolutely large)
# can suggest the context was reconstructed from a compaction summary, since compacted
# sessions tend to serve most tokens from cache rather than fresh input.
# Thresholds: cache_read > input_tokens * 3, OR cache_read > 50000.
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
if [ "$cache_read" -gt 0 ] && [ "$input_tokens" -ge 0 ]; then
  ratio_threshold=$(( input_tokens * 3 ))
  if [ "$cache_read" -gt "$ratio_threshold" ] || [ "$cache_read" -gt 50000 ]; then
    parts+=("$(printf '\033[02;36m\u25ce\033[0m')")  # dim cyan ◎
  fi
fi

# Join parts with separator " | "
sep="$(printf '\033[02;37m | \033[0m')"
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result}${sep}${part}"
  fi
done

printf '%s' "$result"
