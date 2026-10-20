#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s sts-upd
if ! kc k8s -n sts-upd get sts web >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: sts-upd
  labels: {exam.q: "$QID"}
spec:
  clusterIP: None
  selector: {app: web}
  ports:
  - {port: 80, name: web}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
  namespace: sts-upd
  labels: {exam.q: "$QID"}
spec:
  serviceName: web
  replicas: 3
  podManagementPolicy: Parallel
  selector:
    matchLabels: {app: web}
  template:
    metadata:
      labels: {app: web}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        volumeMounts:
        - {name: www, mountPath: /usr/share/nginx/html}
  volumeClaimTemplates:
  - metadata: {name: www}
    spec:
      accessModes: [ReadWriteOnce]
      resources: {requests: {storage: 100Mi}}
YAML
fi
wait_for 150 -- kc k8s -n sts-upd wait --for=jsonpath='{.status.readyReplicas}'=3 sts/web --timeout=2s || log "web not ready yet"
log "q55 seeded"
