#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s spread-demo
kc k8s label node k8s-worker zone=a --overwrite >/dev/null
kc k8s label node k8s-worker2 zone=b --overwrite >/dev/null
kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: spread-demo
  labels: {exam.q: "$QID"}
spec:
  replicas: 4
  selector:
    matchLabels: {app: api}
  template:
    metadata:
      labels: {app: api}
    spec:
      containers:
      - name: api
        image: nginx:1.27
YAML
log "q14 seeded"
