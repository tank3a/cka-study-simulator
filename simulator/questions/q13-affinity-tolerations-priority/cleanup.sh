#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns affinity-demo --ignore-not-found --wait=false
kc k8s delete priorityclass batch-low --ignore-not-found
kc k8s label node k8s-worker tier- zone- >/dev/null 2>&1
kc k8s label node k8s-worker2 tier- zone- >/dev/null 2>&1
exit 0
