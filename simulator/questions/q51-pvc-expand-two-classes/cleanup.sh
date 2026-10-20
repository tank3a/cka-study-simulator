#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns expand2 --ignore-not-found --wait=false
kc k8s delete sc grow-sc fixed-sc --ignore-not-found
term_sh 'rm -f /home/candidate/q51.txt'
exit 0
