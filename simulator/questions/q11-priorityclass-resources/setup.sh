#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s prio-demo
kapply k8s -f - <<YAML
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: platform-high
  labels: {exam.q: "$QID"}
value: 50000
globalDefault: false
description: "Platform components"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: team-mid
  labels: {exam.q: "$QID"}
value: 1000
globalDefault: false
description: "Team workloads"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout
  namespace: prio-demo
  labels: {exam.q: "$QID"}
spec:
  replicas: 2
  selector:
    matchLabels: {app: checkout}
  template:
    metadata:
      labels: {app: checkout}
    spec:
      containers:
      - name: checkout
        image: nginx:1.27
YAML
log "q11 seeded"
