#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=job-demo
check_eq "completions 6 / parallelism 2 / backoffLimit 3" 2 "6 2 3" -- \
  kc k8s -n $NS get job batch-calc -o jsonpath='{.spec.completions} {.spec.parallelism} {.spec.backoffLimit}'
check_eq "activeDeadlineSeconds 120, ttlSecondsAfterFinished 600" 1 "120 600" -- \
  kc k8s -n $NS get job batch-calc -o jsonpath='{.spec.activeDeadlineSeconds} {.spec.ttlSecondsAfterFinished}'
check_jsonpath "restartPolicy Never" 1 k8s job/batch-calc -n $NS '{.spec.template.spec.restartPolicy}' "Never"
check_eventually "Job completed (6 succeeded)" 2 120 -- \
  kc k8s -n $NS wait --for=condition=Complete job/batch-calc --timeout=2s
check_file "log of a Pod saved" 1 term /home/candidate/job-out.txt '^done-batch-calc-'
