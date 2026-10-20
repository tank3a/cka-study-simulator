#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=vpa-b
V=verticalpodautoscalers.v1.autoscaling.k8s.io
check_eq "targetRef is Deployment web (apps/v1)" 2 "apps/v1 Deployment web" -- \
  kc k8s -n $NS get $V web-vpa -o jsonpath='{.spec.targetRef.apiVersion} {.spec.targetRef.kind} {.spec.targetRef.name}'
check_jsonpath "updateMode Initial" 2 k8s $V/web-vpa -n $NS '{.spec.updatePolicy.updateMode}' "Initial"
check_eq "container web: controlledValues RequestsOnly" 2 "RequestsOnly" -- \
  kc k8s -n $NS get $V web-vpa -o jsonpath='{.spec.resourcePolicy.containerPolicies[?(@.containerName=="web")].controlledValues}'
check_eq "container log-sidecar: mode Off" 2 "Off" -- \
  kc k8s -n $NS get $V web-vpa -o jsonpath='{.spec.resourcePolicy.containerPolicies[?(@.containerName=="log-sidecar")].mode}'
# only counts once the VPA was edited (untouched state must not score)
check_sh "VPA was edited, not recreated (label kept)" 1 \
  '[ "$(kc k8s -n vpa-b get verticalpodautoscalers.v1.autoscaling.k8s.io web-vpa -o jsonpath="{.spec.updatePolicy.updateMode}/{.metadata.labels.exam\.q}")" = "Initial/q62-vpa-fix-targetref-sidecar" ]'
