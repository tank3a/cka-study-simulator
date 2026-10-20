#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s -n sc-demo delete deploy,pvc --all --ignore-not-found --wait=true --timeout=60s
kc k8s delete sc fast-local --ignore-not-found
# PVs left by the Retain policy
kc k8s get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="sc-demo")]}{.metadata.name}{"\n"}{end}' 2>/dev/null \
  | while read -r pv; do [ -n "$pv" ] && kc k8s delete pv "$pv" --ignore-not-found; done
kc k8s delete ns sc-demo --ignore-not-found --wait=false
