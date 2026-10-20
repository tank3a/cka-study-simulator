#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s retain-demo
for n in k8s-worker k8s-worker2; do
  on_node "$n" mkdir -p /mnt/legacy /mnt/reports /mnt/scratch /mnt/archive
done

kapply k8s -f - <<YAML
apiVersion: v1
kind: PersistentVolume
metadata:
  name: legacy-pv
  labels: {exam.q: "$QID"}
spec:
  capacity: {storage: 1Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Delete
  storageClassName: legacy
  hostPath: {path: /mnt/legacy}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: reports-pv
  labels: {exam.q: "$QID", tier: reports}
spec:
  capacity: {storage: 5Gi}
  accessModes: [ReadOnlyMany]
  persistentVolumeReclaimPolicy: Retain
  hostPath: {path: /mnt/reports}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: scratch-pv
  labels: {exam.q: "$QID", tier: reports}
spec:
  capacity: {storage: 5Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  hostPath: {path: /mnt/scratch}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: archive-pv
  labels: {exam.q: "$QID", tier: archive}
spec:
  capacity: {storage: 5Gi}
  accessModes: [ReadOnlyMany]
  persistentVolumeReclaimPolicy: Retain
  hostPath: {path: /mnt/archive}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: legacy-pvc
  namespace: retain-demo
  labels: {exam.q: "$QID"}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: legacy
  volumeName: legacy-pv
  resources: {requests: {storage: 1Gi}}
YAML
log "q03 seeded"
