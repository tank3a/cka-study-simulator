#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=affinity-demo
A='.spec.template.spec.affinity'
check_eq "required nodeAffinity tier In [app]" 2 "tier In app" -- \
  kc k8s -n $NS get deploy web-tier -o jsonpath="{$A.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key} {$A.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator} {$A.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]}"
check_eq "preferred nodeAffinity zone=a weight 80" 2 "80 zone a" -- \
  kc k8s -n $NS get deploy web-tier -o jsonpath="{$A.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight} {$A.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].key} {$A.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].values[0]}"
check_eq "required podAntiAffinity on hostname for app=web-tier" 2 "kubernetes.io/hostname web-tier" -- \
  kc k8s -n $NS get deploy web-tier -o jsonpath="{$A.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey} {$A.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchLabels.app}"
ro_web() { [ -n "$(kc k8s -n $NS get deploy web-tier -o jsonpath='{.spec.template.spec.affinity}')" ] && kc k8s -n $NS rollout status deploy/web-tier --timeout=2s; }
check_eventually "web-tier rollout complete" 1 60 -- ro_web
# placement/taint checks only count once the rules are configured (default spreading already gives 1+1 by chance)
check_sh "web-tier Pods run on two different worker nodes" 2 \
  '[ -n "$(kc k8s -n affinity-demo get deploy web-tier -o jsonpath="{.spec.template.spec.affinity.podAntiAffinity}")" ] && [ "$(kc k8s -n affinity-demo get pods -l app=web-tier --field-selector=status.phase=Running -o jsonpath="{.items[*].spec.nodeName}" | tr " " "\n" | sort -u | paste -sd, -)" = "k8s-worker,k8s-worker2" ]'
check_eventually "node-agent runs on all 3 nodes" 3 120 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.numberReady}'=3 ds/node-agent --timeout=2s
check_jsonpath "PriorityClass batch-low value 100" 1 k8s priorityclass/batch-low '{.value}' "100"
check_jsonpath "PriorityClass batch-low preemptionPolicy Never" 2 k8s priorityclass/batch-low '{.preemptionPolicy}' "Never"
check_jsonpath "report-gen uses batch-low" 1 k8s deploy/report-gen -n $NS '{.spec.template.spec.priorityClassName}' "batch-low"
rg_ok() { [ "$(kc k8s -n $NS get deploy report-gen -o jsonpath='{.spec.template.spec.priorityClassName}')" = batch-low ] && kc k8s -n $NS rollout status deploy/report-gen --timeout=2s; }
check_eventually "report-gen Available" 1 60 -- rg_ok
cptaint() { [ -n "$(kc k8s -n affinity-demo get ds node-agent -o jsonpath='{.spec.template.spec.tolerations}')" ] && kc k8s get node "$@"; }
check_eq "control-plane taint still present" 1 "NoSchedule" -- \
  cptaint k8s-control-plane -o jsonpath='{.spec.taints[?(@.key=="node-role.kubernetes.io/control-plane")].effect}'
