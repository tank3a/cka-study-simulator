#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns aff2 aff2-batch --ignore-not-found --wait=false
exit 0
