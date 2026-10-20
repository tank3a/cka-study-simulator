#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns taint-demo --ignore-not-found --wait=false
kc k8s label node k8s-worker disk- >/dev/null 2>&1
kc k8s label node k8s-worker2 disk- >/dev/null 2>&1
kc k8s taint node k8s-worker2 team- >/dev/null 2>&1
term_sh 'rm -f /home/candidate/noschedule-nodes.txt'
exit 0
