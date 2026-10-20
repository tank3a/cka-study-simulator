#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s cron-demo
if ! kc k8s -n cron-demo get cronjob report >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: batch/v1
kind: CronJob
metadata:
  name: report
  namespace: cron-demo
  labels: {exam.q: "$QID"}
spec:
  schedule: "0 0 31 2 *"
  suspend: true
  concurrencyPolicy: Allow
  successfulJobsHistoryLimit: 10
  failedJobsHistoryLimit: 10
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: report
            image: busybox:1.37
            command: ["sh", "-c", "echo report generated"]
YAML
fi
log "q57 seeded"
