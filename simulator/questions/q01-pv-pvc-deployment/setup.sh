#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s data-app
for n in k8s-worker k8s-worker2; do
  on_node "$n" mkdir -p /mnt/data-app
done
log "q01 seeded"
