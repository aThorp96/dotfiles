#!/usr/bin/env bash

PATH="$HOME/.local/bin:$PATH"

function remove_task {
    TASK=$(taskup list | fuzzel  --dmenu  --prompt "Task to remove: ")
    test -n "${TASK}" && taskup remove "${TASK}" 2>&1
}

function set_task {
    TASK=$(taskup list | fuzzel  --dmenu  --prompt "Task: ")
    test -n "${TASK}" && taskup set "${TASK}" 2>&1
}

function add_task {
    TASK=$(taskup list | fuzzel  --dmenu  --prompt "Add task: ")
    test -n "${TASK}" && taskup add "${TASK}" 2>&1
}

function clear_task {
    test "$(taskup show)" = "(No active task)" && return
    CHOICE=$(echo -e "clear\nstop" | fuzzel  --dmenu  --prompt "$(taskup show) - Clear task? ")
    test "${CHOICE}" = "clear" && taskup clear 2>&1
    test "${CHOICE}" = "stop" && taskup stop
}

if declare -f "$1" >/dev/null 2>&1; then
    "$@"
else
    set_task
fi

