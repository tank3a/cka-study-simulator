#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s sidecar-demo
kapply k8s -f - <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: agent-config
  namespace: sidecar-demo
  labels: {exam.q: "$QID"}
data:
  agent.conf: |
    destination=stdout
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shipper
  namespace: sidecar-demo
  labels: {exam.q: "$QID"}
spec:
  replicas: 2
  selector:
    matchLabels: {app: shipper}
  template:
    metadata:
      labels: {app: shipper}
    spec:
      containers:
      - name: app
        image: busybox:1.37
        command: ["sh", "-c", "mkdir -p /var/log/app; while true; do echo \"\$(date) request handled\" >> /var/log/app/app.log; sleep 3; done"]
        volumeMounts:
        - {name: logs, mountPath: /var/log/app}
      volumes:
      - name: logs
        emptyDir: {}
YAML
log "q10 seeded"
