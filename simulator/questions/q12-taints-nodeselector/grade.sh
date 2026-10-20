#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=taint-demo
check_sh "noschedule-nodes.txt lists exactly the NoSchedule-tainted node(s)" 1 \
  '[ "$(term_sh "sort -u /home/candidate/noschedule-nodes.txt | paste -sd, -")" = "k8s-control-plane" ]'
# the control-plane label value is "" (key only), so test for the key, not for a value
check_sh "cp-monitor nodeSelector targets control-plane" 1 \
  'kc k8s -n taint-demo get deploy cp-monitor -o jsonpath="{.spec.template.spec.nodeSelector}" | grep -q "node-role.kubernetes.io/control-plane"'
check_sh "cp-monitor tolerates the control-plane taint" 1 \
  'kc k8s -n taint-demo get deploy cp-monitor -o jsonpath="{.spec.template.spec.tolerations[*].key}" | grep -q "node-role.kubernetes.io/control-plane"'
ro_cp() { [ -n "$(kc k8s -n taint-demo get deploy cp-monitor -o jsonpath='{.spec.template.spec.nodeSelector}')" ] && kc k8s -n $NS rollout status deploy/cp-monitor --timeout=2s; }
check_eventually "cp-monitor rollout complete" 1 45 -- ro_cp
live_on() { local r; r=$(kc k8s -n $NS get pods -l app=$1 -o json | jq -r '[.items[]|select(.metadata.deletionTimestamp==null)|.spec.nodeName]|unique|join(" ")'); [ "$r" = "$2" ]; }
cp_on() { [ -n "$(kc k8s -n $NS get deploy cp-monitor -o jsonpath='{.spec.template.spec.nodeSelector}')" ] && live_on cp-monitor k8s-control-plane; }
check_eventually "all cp-monitor Pods run on k8s-control-plane" 1 60 -- cp_on
check_jsonpath "node k8s-worker labelled disk=ssd" 1 k8s node/k8s-worker '{.metadata.labels.disk}' "ssd"
check_jsonpath "fast-store nodeSelector disk=ssd" 1 k8s deploy/fast-store -n $NS '{.spec.template.spec.nodeSelector.disk}' "ssd"
ro_fs() { [ "$(kc k8s -n taint-demo get deploy fast-store -o jsonpath='{.spec.template.spec.nodeSelector.disk}')" = ssd ] && kc k8s -n $NS rollout status deploy/fast-store --timeout=2s; }
check_eventually "fast-store rollout complete" 1 45 -- ro_fs
# placement/taint checks only count once the Deployments were changed (default scheduling can place Pods "right" by chance)
fs_nodes() { [ "$(kc k8s -n taint-demo get deploy fast-store -o jsonpath='{.spec.template.spec.nodeSelector.disk}')" = ssd ] && kc k8s "$@"; }
fs_on() { [ "$(kc k8s -n $NS get deploy fast-store -o jsonpath='{.spec.template.spec.nodeSelector.disk}')" = ssd ] && live_on fast-store k8s-worker; }
check_eventually "all fast-store Pods run on k8s-worker" 1 60 -- fs_on
check_eq "k8s-worker2 taint team=blue:PreferNoSchedule" 1 "blue PreferNoSchedule" -- \
  kc k8s get node k8s-worker2 -o jsonpath='{.spec.taints[?(@.key=="team")].value} {.spec.taints[?(@.key=="team")].effect}'
cptaint() { [ -n "$(kc k8s -n taint-demo get deploy cp-monitor -o jsonpath='{.spec.template.spec.tolerations}')" ] && kc k8s get node "$@"; }
check_eq "control-plane taint unchanged" 1 "NoSchedule" -- \
  cptaint k8s-control-plane -o jsonpath='{.spec.taints[?(@.key=="node-role.kubernetes.io/control-plane")].effect}'
