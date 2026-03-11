#!/bin/bash
# tmux-jump-waiting.sh - Jump to the next tmux window with a waiting agent
# Cycles through waiting windows on repeated presses.
# Bound to prefix+! in tmux.conf

set -euo pipefail

current=$(tmux display-message -p '#I')
first_waiting=""
next_waiting=""

for idx in $(tmux list-windows -F '#I'); do
    status=$(tmux show-window-option -t ":$idx" -v @workmux_status 2>/dev/null || true)
    if [[ "$status" == *"💬"* ]]; then
        [ -z "$first_waiting" ] && first_waiting=$idx
        # Find the first waiting window AFTER current
        if [ "$idx" -gt "$current" ] && [ -z "$next_waiting" ]; then
            next_waiting=$idx
        fi
    fi
done

# Prefer next after current, otherwise wrap to first
target=${next_waiting:-$first_waiting}

if [ -n "$target" ]; then
    tmux select-window -t ":$target"
else
    tmux display-message "No agents waiting"
fi
