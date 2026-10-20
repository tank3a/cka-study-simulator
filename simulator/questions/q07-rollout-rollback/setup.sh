#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s rollout-demo
if ! kc k8s -n rollout-demo get deploy web >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: rollout-demo
  labels: {exam.q: "$QID"}
spec:
  replicas: 4
  selector:
    matchLabels: {app: web}
  template:
    metadata:
      labels: {app: web}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
YAML
  kc k8s -n rollout-demo rollout status deploy/web --timeout=120s
  # second revision: a broken image so the rollout gets stuck
  kc k8s -n rollout-demo set image deploy/web nginx=nginx:1.27-doesnotexist
fi
term_sh 'rm -f /home/candidate/web-history.txt'
log "q07 seeded"
