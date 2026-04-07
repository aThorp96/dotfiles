#!/usr/bin/env bash

if [[ "$1" == "up" ]]; then
    shift
    exec start_devpod "$@"
elif [[ "$1" == "-i" ]]; then
    shift
    exec podman exec -ti devaipod devaipod "$@"
elif [[ "$1" == "open" ]]; then
    port=$(podman port devaipod | cut -d '/' -f 1)
    exec xdg-open "http://localhost:${port}"
else
    exec podman exec devaipod devaipod "$@"
fi
