#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s taint-demo
# reset node state touched by this task
kc k8s label node k8s-worker disk- >/dev/null 2>&1
kc k8s label node k8s-worker2 disk- >/dev/null 2>&1
kc k8s taint node k8s-worker2 team- >/dev/null 2>&1
term_sh 'rm -f /home/candidate/noschedule-nodes.txt'
kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cp-monitor
  namespace: taint-demo
  labels: {exam.q: "$QID"}
spec:
  replicas: 1
  selector:
    matchLabels: {app: cp-monitor}
  template:
    metadata:
      labels: {app: cp-monitor}
    spec:
      containers:
      - name: monitor
        image: busybox:1.37
        command: ["sleep", "3600"]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fast-store
  namespace: taint-demo
  labels: {exam.q: "$QID"}
spec:
  replicas: 2
  selector:
    matchLabels: {app: fast-store}
  template:
    metadata:
      labels: {app: fast-store}
    spec:
      containers:
      - name: store
        image: nginx:1.27
YAML
log "q12 seeded"
