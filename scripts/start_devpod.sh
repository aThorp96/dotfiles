#!/usr/bin/env bash

CONTAINER="${1:-ghcr.io/cgwalters/devaipod:latest}"

SOCKET="${XDG_RUNTIME_DIR}/podman/podman.sock"
podman volume exists devaipod-state || podman volume create devaipod-state
podman run -d --name devaipod --privileged --replace \
  -p 8080:8080 \
  --add-host=host.containers.internal:host-gateway \
  -v "${SOCKET}:/run/docker.sock" -e "DEVAIPOD_HOST_SOCKET=${SOCKET}" \
  -v devaipod-state:/var/lib/devaipod \
  -v ~/.config/devaipod.toml:/root/.config/devaipod.toml:ro \
  "${CONTAINER}"

