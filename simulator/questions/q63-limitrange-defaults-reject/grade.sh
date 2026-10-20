#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=lr-demo
L='{.spec.limits[0]'
check_eq "LimitRange type Container, default 500m/256Mi" 2 "Container 500m 256Mi" -- \
  kc k8s -n $NS get limitrange cpu-mem-limits -o jsonpath="$L.type} $L.default.cpu} $L.default.memory}"
check_eq "defaultRequest 100m/128Mi" 1 "100m 128Mi" -- \
  kc k8s -n $NS get limitrange cpu-mem-limits -o jsonpath="$L.defaultRequest.cpu} $L.defaultRequest.memory}"
check_eq "max 1 / 512Mi, min 50m / 64Mi" 2 "1 512Mi 50m 64Mi" -- \
  kc k8s -n $NS get limitrange cpu-mem-limits -o jsonpath="$L.max.cpu} $L.max.memory} $L.min.cpu} $L.min.memory}"
check_eq "Pod plain received default limits" 1 "500m 256Mi" -- \
  kc k8s -n $NS get pod plain -o jsonpath='{.spec.containers[0].resources.limits.cpu} {.spec.containers[0].resources.limits.memory}'
check_eq "Pod plain received default requests" 1 "100m 128Mi" -- \
  kc k8s -n $NS get pod plain -o jsonpath='{.spec.containers[0].resources.requests.cpu} {.spec.containers[0].resources.requests.memory}'
check_sh "Pod toobig does not exist" 1 '! kc k8s -n lr-demo get pod toobig'
check_file "rejection message saved" 1 term /home/candidate/lr-error.txt 'maximum cpu usage per Container'
