#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s -n vol-demo delete pod,pvc --all --ignore-not-found --wait=true --timeout=60s
kc k8s delete pv raw-pv --ignore-not-found
kc k8s delete ns vol-demo --ignore-not-found --wait=false
