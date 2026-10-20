#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=vpa-a
V=verticalpodautoscalers.v1.autoscaling.k8s.io
check_eq "targetRef is Deployment sizing-target" 2 "Deployment sizing-target" -- \
  kc k8s -n $NS get $V sizing-vpa -o jsonpath='{.spec.targetRef.kind} {.spec.targetRef.name}'
check_jsonpath "updateMode Off" 2 k8s $V/sizing-vpa -n $NS '{.spec.updatePolicy.updateMode}' "Off"
check_eq "container app minAllowed 50m / 64Mi" 1 "app 50m 64Mi" -- \
  kc k8s -n $NS get $V sizing-vpa -o jsonpath='{.spec.resourcePolicy.containerPolicies[0].containerName} {.spec.resourcePolicy.containerPolicies[0].minAllowed.cpu} {.spec.resourcePolicy.containerPolicies[0].minAllowed.memory}'
check_eq "container app maxAllowed 500m / 512Mi" 1 "500m 512Mi" -- \
  kc k8s -n $NS get $V sizing-vpa -o jsonpath='{.spec.resourcePolicy.containerPolicies[0].maxAllowed.cpu} {.spec.resourcePolicy.containerPolicies[0].maxAllowed.memory}'
check_eq "controlledResources cpu,memory" 1 "cpu memory" -- \
  kc k8s -n $NS get $V sizing-vpa -o jsonpath='{.spec.resourcePolicy.containerPolicies[0].controlledResources[*]}'
