#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=prio-demo
check_jsonpath "PriorityClass business-critical value 49999" 2 k8s priorityclass/business-critical '{.value}' "49999"
check_sh "business-critical is not globalDefault" 1 \
  'g=$(kc k8s get priorityclass business-critical -o jsonpath="{.globalDefault}") && [ "$g" != "true" ]'
check_jsonpath "business-critical description" 1 k8s priorityclass/business-critical '{.description}' "Business critical workloads"
check_sh "platform-high untouched (50000)" 1 'kc k8s get priorityclass business-critical >/dev/null 2>&1 && [ "$(kc k8s get priorityclass platform-high -o jsonpath="{.value}")" = 50000 ]'
check_jsonpath "Deployment uses business-critical" 1 k8s deploy/checkout -n $NS '{.spec.template.spec.priorityClassName}' "business-critical"
check_eq "requests cpu/memory" 1 "100m 64Mi" -- \
  kc k8s -n $NS get deploy checkout -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu} {.spec.template.spec.containers[0].resources.requests.memory}'
check_eq "limits cpu/memory" 1 "200m 128Mi" -- \
  kc k8s -n $NS get deploy checkout -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu} {.spec.template.spec.containers[0].resources.limits.memory}'
check_eventually "Pods Running with priority 49999" 2 90 -- \
  kc k8s -n $NS wait --for=jsonpath='{.spec.priority}'=49999 pod -l app=checkout --timeout=2s
check_eventually "Deployment checkout Available" 1 90 -- \
  kc k8s -n $NS wait --for=condition=Available deploy/checkout --timeout=2s
