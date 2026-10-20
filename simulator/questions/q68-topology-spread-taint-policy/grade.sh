#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=spread2
T='{.spec.template.spec.topologySpreadConstraints[0]'
# placement/taint checks only count once the constraint is fixed (default spreading already gives 2/2 by chance)
FIX() { [ "$(kc k8s -n spread2 get deploy spread-app -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].maxSkew}/{.spec.template.spec.topologySpreadConstraints[0].labelSelector.matchLabels.app}')" = "1/spread-app" ]; }
cnt() { FIX || return 1; kc k8s -n spread2 get pods -l app=spread-app --field-selector=status.phase=Running -o jsonpath='{.items[*].spec.nodeName}' | tr ' ' '\n' | grep -c "^$1$"; }
check_eq "maxSkew 1, DoNotSchedule, hostname" 2 "1 DoNotSchedule kubernetes.io/hostname" -- \
  kc k8s -n $NS get deploy spread-app -o jsonpath="$T.maxSkew} $T.whenUnsatisfiable} $T.topologyKey}"
check_jsonpath "labelSelector matches the Deployment's Pods" 1 k8s deploy/spread-app -n $NS "$T.labelSelector.matchLabels.app}" "spread-app"
check_eventually "all 4 replicas Running" 2 150 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.readyReplicas}'=4 deploy/spread-app --timeout=2s
check_eq "2 Pods on k8s-worker" 1 "2" -- cnt k8s-worker
check_eq "2 Pods on k8s-worker2" 1 "2" -- cnt k8s-worker2
cptaint() { FIX && kc k8s get node k8s-control-plane "$@"; }
check_eq "control-plane taint unchanged" 1 "NoSchedule" -- \
  cptaint -o jsonpath='{.spec.taints[?(@.key=="node-role.kubernetes.io/control-plane")].effect}'
