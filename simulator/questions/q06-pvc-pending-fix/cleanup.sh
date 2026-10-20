#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s -n pvc-fix delete deploy,pvc --all --ignore-not-found --wait=true --timeout=60s
kc k8s delete pv pv-ledger --ignore-not-found
kc k8s delete ns pvc-fix --ignore-not-found --wait=false
