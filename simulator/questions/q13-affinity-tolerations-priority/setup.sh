#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s affinity-demo
kc k8s label node k8s-worker tier=app zone=a --overwrite >/dev/null
kc k8s label node k8s-worker2 tier=app zone=b --overwrite >/dev/null
kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-tier
  namespace: affinity-demo
  labels: {exam.q: "$QID"}
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate: {maxSurge: 0, maxUnavailable: 1}
  selector:
    matchLabels: {app: web-tier}
  template:
    metadata:
      labels: {app: web-tier}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-agent
  namespace: affinity-demo
  labels: {exam.q: "$QID"}
spec:
  selector:
    matchLabels: {app: node-agent}
  template:
    metadata:
      labels: {app: node-agent}
    spec:
      containers:
      - name: agent
        image: busybox:1.37
        command: ["sleep", "3600"]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: report-gen
  namespace: affinity-demo
  labels: {exam.q: "$QID"}
spec:
  replicas: 1
  selector:
    matchLabels: {app: report-gen}
  template:
    metadata:
      labels: {app: report-gen}
    spec:
      containers:
      - name: gen
        image: busybox:1.37
        command: ["sleep", "3600"]
YAML
log "q13 seeded"
