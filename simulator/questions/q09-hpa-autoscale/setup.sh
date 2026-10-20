#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s hpa-demo
kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: hpa-demo
  labels: {exam.q: "$QID"}
spec:
  replicas: 1
  selector:
    matchLabels: {app: web}
  template:
    metadata:
      labels: {app: web}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
YAML
log "q09 seeded"
