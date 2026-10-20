#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=quota-a
check_used() { [ "$(kc k8s -n quota-a get resourcequota team-quota -o jsonpath="{.status.used.pods} {.status.used.requests\\.cpu}")" = "3 600m" ]; }
Q() { kc k8s -n quota-a get resourcequota team-quota -o jsonpath="$1"; }
check_eq "quota pods=4, requests.cpu=1, requests.memory=1Gi" 2 "4 1 1Gi" -- \
  Q "{.spec.hard.pods} {.spec.hard.requests\\.cpu} {.spec.hard.requests\\.memory}"
check_eq "quota limits.cpu=2, limits.memory=2Gi" 2 "2 2Gi" -- \
  Q "{.spec.hard.limits\\.cpu} {.spec.hard.limits\\.memory}"
check_eventually "Deployment app: 3 available replicas" 2 150 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.availableReplicas}'=3 deploy/app --timeout=2s
check_eq "container requests 200m/128Mi, limits 400m/256Mi" 1 "200m 128Mi 400m 256Mi" -- \
  kc k8s -n $NS get deploy app -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu} {.spec.template.spec.containers[0].resources.requests.memory} {.spec.template.spec.containers[0].resources.limits.cpu} {.spec.template.spec.containers[0].resources.limits.memory}'
check_eventually "quota usage shows 3 pods and 600m cpu requested" 1 90 -- \
  check_used
