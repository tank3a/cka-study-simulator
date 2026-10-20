#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=ds-demo
check_jsonpath "DaemonSet nodeSelector disk=ssd" 1 k8s ds/log-agent -n $NS '{.spec.template.spec.nodeSelector.disk}' "ssd"
check_jsonpath "updateStrategy RollingUpdate" 1 k8s ds/log-agent -n $NS '{.spec.updateStrategy.type}' "RollingUpdate"
check_jsonpath "maxUnavailable 1" 1 k8s ds/log-agent -n $NS '{.spec.updateStrategy.rollingUpdate.maxUnavailable}' "1"
check_jsonpath "hostPath /var/log" 1 k8s ds/log-agent -n $NS '{.spec.template.spec.volumes[0].hostPath.path}' "/var/log"
check_eq "mounted read-only at /host-logs" 1 "/host-logs true" -- \
  kc k8s -n $NS get ds log-agent -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[0].mountPath} {.spec.template.spec.containers[0].volumeMounts[0].readOnly}'
check_eq "k8s-worker2 labelled disk=ssd" 1 "ssd" -- kc k8s get node k8s-worker2 -o jsonpath='{.metadata.labels.disk}'
check_eventually "2 Pods ready (both workers)" 2 120 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.numberReady}'=2 ds/log-agent --timeout=2s
check_sh "no Pod on the control-plane node" 1 \
  'kc k8s -n ds-demo get ds log-agent >/dev/null 2>&1 && ! kc k8s -n ds-demo get pods -l app=log-agent -o jsonpath="{.items[*].spec.nodeName}" | grep -q control-plane'
