#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns prio-demo --ignore-not-found --wait=false
kc k8s delete priorityclass business-critical --ignore-not-found
