#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s pdb-a
if ! kc k8s -n pdb-a get deploy api >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: pdb-a
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
      - name: pause
        image: registry.k8s.io/pause:3.10
YAML
fi
wait_ready k8s deploy/api -n pdb-a 90 || log "api not ready yet"
log "q58 seeded"
