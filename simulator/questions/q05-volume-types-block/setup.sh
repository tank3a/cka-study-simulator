#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s vol-demo
kapply k8s -f - <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-conf
  namespace: vol-demo
  labels: {exam.q: "$QID"}
data:
  app.properties: |
    mode=lab
    retries=3
YAML
log "q05 seeded"
