#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s sc-demo
log "q02 seeded"
