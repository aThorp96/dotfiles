#!/usr/bin/env bash

function set_task {
    TASK=$(fuzzel  --dmenu  --prompt-only "Task: ")
    echo "Task being set to '${TASK}'"
    test -n "${TASK}" && "$HOME/.local/bin/taskup" set "${TASK}" 2>&1
}

set_task >> /home/athorp/log

