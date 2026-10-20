#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns secret-demo --ignore-not-found --wait=false
term_sh 'rm -rf /home/candidate/certs'
exit 0
