#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s sts-demo
# DNS probe Pod used by grade.sh (not part of the task text)
if ! kc k8s -n sts-demo get pod dns-probe >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: dns-probe
  namespace: sts-demo
  labels: {exam.q: "$QID"}
spec:
  containers:
  - name: probe
    image: busybox:1.37
    command: ["sleep", "7200"]
YAML
fi
log "q54 seeded"
