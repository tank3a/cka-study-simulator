#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s spread2
if ! kc k8s -n spread2 get deploy spread-app >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spread-app
  namespace: spread2
  labels: {exam.q: "$QID"}
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate: {maxSurge: 0, maxUnavailable: 1}
  selector:
    matchLabels: {app: spread-app}
  template:
    metadata:
      labels: {app: spread-app}
    spec:
      topologySpreadConstraints:
      - maxSkew: 3
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels: {app: spreadapp}
      containers:
      - name: pause
        image: registry.k8s.io/pause:3.10
YAML
fi
log "q68 seeded"
