#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=expand2
check_jsonpath "grow-sc allows volume expansion" 1 k8s sc/grow-sc '{.allowVolumeExpansion}' "true"
# "unchanged" checks only count once orders-db was expanded (untouched state must not score)
G='[ "$(kc k8s -n expand2 get pvc orders-db -o jsonpath="{.spec.resources.requests.storage}")" = 2Gi ]'
check_sh "fixed-sc still forbids expansion" 1 "$G"' && [ "$(kc k8s get sc fixed-sc -o jsonpath="{.allowVolumeExpansion}")" = false ]'
check_jsonpath "PVC orders-db requests 2Gi" 2 k8s pvc/orders-db -n $NS '{.spec.resources.requests.storage}' "2Gi"
check_sh "PVC archive still requests 500Mi" 1 "$G"' && [ "$(kc k8s -n expand2 get pvc archive -o jsonpath="{.spec.resources.requests.storage}")" = 500Mi ]'
check_file "result line written" 1 term /home/candidate/q51.txt '^grow-sc[[:space:]]+true[[:space:]]*$'
