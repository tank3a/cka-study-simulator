#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s pvc-fix
for n in k8s-worker k8s-worker2; do
  on_node "$n" mkdir -p /mnt/ledger
done
kapply k8s -f - <<YAML
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-ledger
  labels: {exam.q: "$QID"}
spec:
  capacity: {storage: 5Gi}
  accessModes: [ReadWriteMany]
  volumeMode: Filesystem
  storageClassName: shared-slow
  persistentVolumeReclaimPolicy: Retain
  hostPath: {path: /mnt/ledger}
YAML
# The broken claim and deployment are only created if the claim does not exist (PVC spec is immutable).
if ! kc k8s -n pvc-fix get pvc ledger-pvc >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ledger-pvc
  namespace: pvc-fix
  labels: {exam.q: "$QID"}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: fast
  volumeMode: Block
  resources: {requests: {storage: 3Gi}}
YAML
fi
kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ledger-app
  namespace: pvc-fix
  labels: {exam.q: "$QID"}
spec:
  replicas: 1
  selector:
    matchLabels: {app: ledger-app}
  template:
    metadata:
      labels: {app: ledger-app}
    spec:
      containers:
      - name: app
        image: nginx:1.27
        volumeMounts:
        - {name: ledger, mountPath: /var/ledger}
      volumes:
      - name: ledger
        persistentVolumeClaim: {claimName: ledger-pvc}
YAML
log "q06 seeded"
