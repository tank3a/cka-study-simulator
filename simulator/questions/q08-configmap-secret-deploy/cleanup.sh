#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

kc k8s delete ns cfg-demo --ignore-not-found --wait=false
term_sh 'rm -f /home/candidate/app.properties'
