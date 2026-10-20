#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s cfg-demo
term_put /home/candidate/app.properties 0644 <<'PROPS'
server.port=8080
feature.beta=true
PROPS
kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: cfg-demo
  labels: {exam.q: "$QID"}
spec:
  replicas: 2
  selector:
    matchLabels: {app: api}
  template:
    metadata:
      labels: {app: api}
    spec:
      containers:
      - name: api
        image: busybox:1.37
        command: ["sleep", "3600"]
YAML
log "q08 seeded"
