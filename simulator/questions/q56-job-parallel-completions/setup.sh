#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s job-demo
log "q56 seeded"
