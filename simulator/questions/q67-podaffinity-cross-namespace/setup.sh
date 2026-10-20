#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s aff2
ns_create k8s aff2-batch
kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: batch-noisy
  namespace: aff2-batch
  labels: {exam.q: "$QID"}
spec:
  replicas: 1
  selector:
    matchLabels: {app: batch-noisy}
  template:
    metadata:
      labels: {app: batch-noisy}
    spec:
      nodeSelector: {kubernetes.io/hostname: k8s-worker}
      containers:
      - name: noisy
        image: registry.k8s.io/pause:3.10
YAML
for n in cache:1 frontend:2; do
  name=${n%%:*}; rep=${n##*:}
  if ! kc k8s -n aff2 get deploy "$name" >/dev/null 2>&1; then
    kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $name
  namespace: aff2
  labels: {exam.q: "$QID"}
spec:
  replicas: $rep
  strategy:
    type: Recreate
  selector:
    matchLabels: {app: $name}
  template:
    metadata:
      labels: {app: $name}
    spec:
      containers:
      - name: main
        image: registry.k8s.io/pause:3.10
YAML
  fi
done
log "q67 seeded"
