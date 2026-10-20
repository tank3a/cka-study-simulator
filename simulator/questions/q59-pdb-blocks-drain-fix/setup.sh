#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s pdb-b
if ! kc k8s -n pdb-b get deploy critical >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical
  namespace: pdb-b
  labels: {exam.q: "$QID"}
spec:
  replicas: 2
  selector:
    matchLabels: {app: critical}
  template:
    metadata:
      labels: {app: critical}
    spec:
      containers:
      - name: pause
        image: registry.k8s.io/pause:3.10
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: critical-pdb
  namespace: pdb-b
  labels: {exam.q: "$QID"}
spec:
  minAvailable: 2
  selector:
    matchLabels: {app: critical}
YAML
fi
wait_ready k8s deploy/critical -n pdb-b 90 || log "critical not ready yet"
log "q59 seeded"
