#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=spread-demo
T='{.spec.template.spec.topologySpreadConstraints[0]'
check_eq "topologySpreadConstraints maxSkew/topologyKey/whenUnsatisfiable" 3 "1 zone DoNotSchedule" -- \
  kc k8s -n $NS get deploy api -o jsonpath="$T.maxSkew} $T.topologyKey} $T.whenUnsatisfiable}"
check_eq "constraint labelSelector app=api" 1 "api" -- \
  kc k8s -n $NS get deploy api -o jsonpath="$T.labelSelector.matchLabels.app}"
check_eq "strategy RollingUpdate maxSurge 1 maxUnavailable 1" 2 "RollingUpdate 1 1" -- \
  kc k8s -n $NS get deploy api -o jsonpath='{.spec.strategy.type} {.spec.strategy.rollingUpdate.maxSurge} {.spec.strategy.rollingUpdate.maxUnavailable}'
check_jsonpath "container cpu request 50m" 1 k8s deploy/api -n $NS '{.spec.template.spec.containers[0].resources.requests.cpu}' "50m"
check_eq "HPA api-hpa target and replicas" 1 "api 4 6" -- \
  kc k8s -n $NS get hpa api-hpa -o jsonpath='{.spec.scaleTargetRef.name} {.spec.minReplicas} {.spec.maxReplicas}'
check_eq "HPA cpu Utilization 80" 1 "cpu Utilization 80" -- \
  kc k8s -n $NS get hpa api-hpa -o jsonpath='{.spec.metrics[0].resource.name} {.spec.metrics[0].resource.target.type} {.spec.metrics[0].resource.target.averageUtilization}'
ro_api() { [ -n "$(kc k8s -n $NS get deploy api -o jsonpath='{.spec.template.spec.topologySpreadConstraints}')" ] && kc k8s -n $NS rollout status deploy/api --timeout=2s; }
check_eventually "rollout complete" 1 90 -- ro_api
# count only Running pods that are not terminating (old ReplicaSet pods linger for a few seconds after the rollout)
check_eventually "exactly 2 Pods in each zone (one per worker node)" 3 60 -- bash -c "[ -n \"\$(kubectl --kubeconfig '$ADMIN_KUBECONFIG' --context k8s -n spread-demo get deploy api -o jsonpath='{.spec.template.spec.topologySpreadConstraints}')\" ] && kubectl --kubeconfig '$ADMIN_KUBECONFIG' --context k8s -n spread-demo get pods -l app=api -o json | jq -r '.items[]|select(.status.phase==\"Running\" and .metadata.deletionTimestamp==null)|.spec.nodeName' | sort | uniq -c | awk '{print \$1}' | paste -sd, - | grep -qx '2,2'"
