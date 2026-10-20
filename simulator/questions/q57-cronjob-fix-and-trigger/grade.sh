#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=cron-demo
check_jsonpath "schedule */5 * * * *" 1 k8s cronjob/report -n $NS '{.spec.schedule}' "*/5 * * * *"
check_jsonpath "suspend false" 1 k8s cronjob/report -n $NS '{.spec.suspend}' "false"
check_jsonpath "concurrencyPolicy Forbid" 1 k8s cronjob/report -n $NS '{.spec.concurrencyPolicy}' "Forbid"
check_eq "history limits 2 / 1" 1 "2 1" -- \
  kc k8s -n $NS get cronjob report -o jsonpath='{.spec.successfulJobsHistoryLimit} {.spec.failedJobsHistoryLimit}'
check_jsonpath "startingDeadlineSeconds 60" 1 k8s cronjob/report -n $NS '{.spec.startingDeadlineSeconds}' "60"
check_jsonpath "Job report-manual owned by CronJob report" 2 k8s job/report-manual -n $NS '{.metadata.ownerReferences[0].name}' "report"
check_eventually "report-manual completed" 1 90 -- kc k8s -n $NS wait --for=condition=Complete job/report-manual --timeout=2s
