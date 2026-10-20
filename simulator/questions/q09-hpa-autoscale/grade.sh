#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=hpa-demo
check_eq "HPA targets Deployment web" 1 "Deployment/web" -- \
  kc k8s -n $NS get hpa web-hpa -o jsonpath='{.spec.scaleTargetRef.kind}/{.spec.scaleTargetRef.name}'
check_eq "HPA min 2 max 8" 1 "2 8" -- \
  kc k8s -n $NS get hpa web-hpa -o jsonpath='{.spec.minReplicas} {.spec.maxReplicas}'
check_eq "HPA metric: cpu Utilization 60" 2 "cpu Utilization 60" -- \
  kc k8s -n $NS get hpa web-hpa -o jsonpath='{.spec.metrics[0].resource.name} {.spec.metrics[0].resource.target.type} {.spec.metrics[0].resource.target.averageUtilization}'
check_jsonpath "scaleDown stabilizationWindowSeconds 30" 1 k8s hpa/web-hpa -n $NS '{.spec.behavior.scaleDown.stabilizationWindowSeconds}' "30"
check_sh "Deployment has a cpu request on the container" 1 \
  '[ -n "$(kc k8s -n hpa-demo get deploy web -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}")" ]'
check_eventually "HPA reports a current CPU utilization (not unknown)" 2 150 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' hpa/web-hpa --timeout=2s
check_eventually "Deployment scaled to at least 2 replicas" 1 120 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.availableReplicas}'=2 deploy/web --timeout=2s
