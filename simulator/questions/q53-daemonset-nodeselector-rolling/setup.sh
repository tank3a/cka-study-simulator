#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s ds-demo
kc k8s label node k8s-worker disk=ssd --overwrite >/dev/null
log "q53 seeded"
