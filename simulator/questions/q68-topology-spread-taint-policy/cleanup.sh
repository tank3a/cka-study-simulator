#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns spread2 --ignore-not-found --wait=false
exit 0
