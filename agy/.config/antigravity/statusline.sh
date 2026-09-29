#!/bin/bash
input=$(cat)

# --- Model ---
model=$(echo "$input" | jq -r '.modelName // .model.display_name // .model.id // empty')

# --- Workspace / CWD ---
cwd=$(echo "$input" | jq -r '.workspacePaths[0] // .cwd // empty')
[ -z "$cwd" ] && cwd="$PWD"

# --- Git branch ---
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# --- Context usage ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // .contextUsage.usedPercentage // empty')

# --- Build output parts ---
parts=()

# 1. Model (cyan)
if [ -n "$model" ]; then
  parts+=("$(printf '\033[01;36m%s\033[0m' "$model")")
fi

# 2. Git branch (yellow con icono Powerline)
if [ -n "$git_branch" ]; then
  parts+=("$(printf '\033[01;33m\uE0A0 %s\033[0m' "$git_branch")")
fi

# 3. user@host:dir (verde user@host, azul último directorio)
dir_name=$(basename "$cwd")
user_host_path="$(printf '\033[01;32m%s@%s\033[0m:\033[01;34m%s\033[0m' "$(whoami)" "$(hostname -s)" "$dir_name")"
parts+=("$user_host_path")

# 4. Context used % — Barra de progreso ASCII
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 75 ]; then
    ctx_color='\033[01;31m'        # bold red
  elif [ "$used_int" -ge 50 ]; then
    ctx_color='\033[01;38;5;208m'  # bold orange
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

# Unir partes con separador " | " en gris atenuado
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
