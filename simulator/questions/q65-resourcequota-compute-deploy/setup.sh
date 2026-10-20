#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s quota-a
if ! kc k8s -n quota-a get deploy app >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  namespace: quota-a
  labels: {exam.q: "$QID"}
spec:
  replicas: 3
  selector:
    matchLabels: {app: quota-app}
  template:
    metadata:
      labels: {app: quota-app}
    spec:
      containers:
      - name: app
        image: registry.k8s.io/pause:3.10
YAML
fi
wait_ready k8s deploy/app -n quota-a 90 || log "app not ready yet"
log "q65 seeded"
