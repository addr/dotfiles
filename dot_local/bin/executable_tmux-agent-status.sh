#!/bin/bash
# tmux-agent-status.sh - Aggregated agent status for tmux status-right
# Shows all workmux-managed windows with their agent state, waiting first.
# Called by tmux every status-interval (5s) via: #(~/.local/bin/tmux-agent-status.sh)

set -eo pipefail

waiting=()
done_list=()
working=()

while IFS=$'\t' read -r name status; do
    [ -z "$status" ] && continue

    # Truncate branch name to 12 chars
    short="${name:0:12}"

    case "$status" in
        *💬*) waiting+=("$short:$status") ;;
        *✅*) done_list+=("$short:$status") ;;
        *🤖*) working+=("$short:$status") ;;
    esac
done < <(tmux list-windows -F "#{window_name}	#{@workmux_status}" 2>/dev/null)

# Nothing to show
total=$(( ${#waiting[@]} + ${#done_list[@]} + ${#working[@]} ))
[ "$total" -eq 0 ] && exit 0

output=""

# Waiting first (highlighted) - these need your attention
for item in "${waiting[@]}"; do
    output+="#[fg=#f9e2af,bold]${item}#[default] "
done

# Done next
for item in "${done_list[@]}"; do
    output+="#[fg=#a6e3a1]${item}#[default] "
done

# Working last (subdued)
for item in "${working[@]}"; do
    output+="#[fg=#6c7086,dim]${item}#[default] "
done

# Trim trailing space
printf '%s' "${output% }"
