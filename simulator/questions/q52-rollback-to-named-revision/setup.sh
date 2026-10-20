#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s rollout2
term_sh 'rm -f /home/candidate/history-before.txt'
if ! kc k8s -n rollout2 get deploy shop >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop
  namespace: rollout2
  labels: {exam.q: "$QID"}
  annotations: {kubernetes.io/change-cause: "v1-initial"}
spec:
  replicas: 2
  selector:
    matchLabels: {app: shop}
  template:
    metadata:
      labels: {app: shop}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
YAML
  kc k8s -n rollout2 rollout status deploy/shop --timeout=90s >/dev/null 2>&1
  step() { # image cause wait
    kc k8s -n rollout2 set image deploy/shop nginx="$1" >/dev/null
    kc k8s -n rollout2 annotate deploy/shop kubernetes.io/change-cause="$2" --overwrite >/dev/null
    if [ "$3" = wait ]; then kc k8s -n rollout2 rollout status deploy/shop --timeout=90s >/dev/null 2>&1; else sleep 3; fi
  }
  step nginx:1.26 v2-stable wait
  step nginx:1.27-alpine v3-experimental wait
  step nginx:1.27-doesnotexist v4-broken nowait
fi
log "q52 seeded"
