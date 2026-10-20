#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s lr-fix
kapply k8s -f - <<YAML
apiVersion: v1
kind: LimitRange
metadata:
  name: container-caps
  namespace: lr-fix
  labels: {exam.q: "$QID"}
spec:
  limits:
  - type: Container
    max: {cpu: 200m, memory: 256Mi}
  - type: PersistentVolumeClaim
    max: {storage: 2Gi}
    min: {storage: 500Mi}
YAML
if ! kc k8s -n lr-fix get deploy worker >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker
  namespace: lr-fix
  labels: {exam.q: "$QID"}
spec:
  replicas: 2
  selector:
    matchLabels: {app: worker}
  template:
    metadata:
      labels: {app: worker}
    spec:
      containers:
      - name: app
        image: busybox:1.37
        command: ["sleep", "3600"]
        resources:
          limits: {cpu: 500m, memory: 128Mi}
      - name: cache
        image: busybox:1.37
        command: ["sleep", "3600"]
        resources:
          limits: {cpu: 100m, memory: 512Mi}
YAML
fi
log "q64 seeded"
