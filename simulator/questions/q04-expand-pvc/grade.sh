#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=expand-demo
check_jsonpath "StorageClass expandable-sc allows volume expansion" 1 k8s sc/expandable-sc '{.allowVolumeExpansion}' "true"
check_jsonpath "PVC data-pvc requests 3Gi" 2 k8s pvc/data-pvc -n $NS '{.spec.resources.requests.storage}' "3Gi"
# constraint checks only count once the claim was expanded (untouched state must not score)
E='[ "$(kc k8s -n expand-demo get pvc data-pvc -o jsonpath="{.spec.resources.requests.storage}")" = 3Gi ]'
check_sh "PVC data-pvc still uses expandable-sc" 1 "$E"' && [ "$(kc k8s -n expand-demo get pvc data-pvc -o jsonpath="{.spec.storageClassName}")" = expandable-sc ]'
check_sh "Pod data-writer still Running (not recreated with other data)" 1 "$E"' && [ "$(kc k8s -n expand-demo get pod data-writer -o jsonpath="{.status.phase}")" = Running ]'
