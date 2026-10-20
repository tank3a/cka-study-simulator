#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns quota-b --ignore-not-found --wait=false
term_sh 'rm -rf /home/candidate/quota-tests /home/candidate/quota-errors.txt'
exit 0
