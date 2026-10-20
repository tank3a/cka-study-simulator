#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns lr-demo --ignore-not-found --wait=false
term_sh 'rm -f /home/candidate/lr-plain.yaml /home/candidate/lr-toobig.yaml /home/candidate/lr-error.txt'
exit 0
