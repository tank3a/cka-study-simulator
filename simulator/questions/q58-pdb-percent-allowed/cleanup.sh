#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns pdb-a --ignore-not-found --wait=false
term_sh 'rm -f /home/candidate/q58.txt'
exit 0
