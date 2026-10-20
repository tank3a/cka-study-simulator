#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=lr-fix
check_eventually "Deployment worker has 2 available replicas" 3 120 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.availableReplicas}'=2 deploy/worker --timeout=2s
# only counts once the Deployment runs (untouched state must not score)
check_sh "LimitRange container-caps unchanged (200m / 256Mi / 2Gi)" 2 \
  '[ "$(kc k8s -n lr-fix get deploy worker -o jsonpath="{.status.availableReplicas}")" = 2 ] && [ "$(kc k8s -n lr-fix get limitrange container-caps -o jsonpath="{.spec.limits[0].max.cpu} {.spec.limits[0].max.memory} {.spec.limits[1].max.storage}")" = "200m 256Mi 2Gi" ]'
check_sh "limits were kept on both containers (not removed)" 1 \
  '[ -n "$(kc k8s -n lr-fix get deploy worker -o jsonpath="{.spec.template.spec.containers[?(@.name==\"app\")].resources.limits.cpu}")" ] && [ -n "$(kc k8s -n lr-fix get deploy worker -o jsonpath="{.spec.template.spec.containers[?(@.name==\"cache\")].resources.limits.memory}")" ]'
check_eq "app keeps its memory limit 128Mi, cache keeps cpu 100m" 1 "128Mi 100m" -- \
  kc k8s -n $NS get deploy worker -o jsonpath='{.spec.template.spec.containers[?(@.name=="app")].resources.limits.memory} {.spec.template.spec.containers[?(@.name=="cache")].resources.limits.cpu}'
check_eq "PVC worker-data 1Gi RWO" 1 "1Gi ReadWriteOnce" -- \
  kc k8s -n $NS get pvc worker-data -o jsonpath='{.spec.resources.requests.storage} {.spec.accessModes[0]}'
