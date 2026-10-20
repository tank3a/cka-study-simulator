#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns job-demo --ignore-not-found --wait=false
term_sh 'rm -f /home/candidate/job-out.txt'
exit 0
