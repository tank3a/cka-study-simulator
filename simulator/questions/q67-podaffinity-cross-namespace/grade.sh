#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=aff2
A='{.spec.template.spec.affinity'
# placement checks only count once both affinity rules are configured (default spreading can place Pods "right" by chance)
CFG() { [ -n "$(kc k8s -n aff2 get deploy cache -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity}')" ] && [ -n "$(kc k8s -n aff2 get deploy frontend -o jsonpath='{.spec.template.spec.affinity.podAffinity}')" ]; }
check_sh_cache() { CFG && [ "$(kc k8s -n aff2 get pods -l app=cache --field-selector=status.phase=Running -o jsonpath='{.items[*].spec.nodeName}')" = "k8s-worker2" ]; }
check_eq "cache: required podAntiAffinity selects app=batch-noisy" 2 "batch-noisy kubernetes.io/hostname aff2-batch" -- \
  kc k8s -n $NS get deploy cache -o jsonpath="$A.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchLabels.app} $A.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey} $A.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].namespaces[0]}"
check_eq "frontend: required podAffinity selects app=cache on hostname" 2 "cache kubernetes.io/hostname" -- \
  kc k8s -n $NS get deploy frontend -o jsonpath="$A.podAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchLabels.app} $A.podAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey}"
check_eventually "cache Running on k8s-worker2" 1 120 -- check_sh_cache
fe_ready() { CFG && kc k8s -n aff2 wait "$@"; }
check_eventually "frontend: 2 Running Pods" 1 120 -- \
  fe_ready --for=jsonpath='{.status.readyReplicas}'=2 deploy/frontend --timeout=2s
check_sh "all frontend Pods run on the cache node" 2 \
  'CFG && [ "$(kc k8s -n aff2 get pods -l app=frontend --field-selector=status.phase=Running -o jsonpath="{.items[*].spec.nodeName}" | tr " " "\n" | sort -u)" = "$(kc k8s -n aff2 get pods -l app=cache --field-selector=status.phase=Running -o jsonpath="{.items[*].spec.nodeName}")" ]'
