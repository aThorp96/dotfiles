#!/usr/bin/env bash

pass show github/devaipod-pat | podman secret create gh_token -
pass show gitlab/pat | podman secret create gl_token -
pass show jira/token | podman secret create jira_api_token -
