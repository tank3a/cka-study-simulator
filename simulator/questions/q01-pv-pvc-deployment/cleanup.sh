#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s -n data-app delete deploy,pvc --all --ignore-not-found --wait=true --timeout=60s
kc k8s delete pv pv-data --ignore-not-found
kc k8s delete ns data-app --ignore-not-found --wait=false
