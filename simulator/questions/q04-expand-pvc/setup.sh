#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s expand-demo
# Create the StorageClass only if it does not exist yet (do not undo the candidate's fix).
if ! kc k8s get sc expandable-sc >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: expandable-sc
  labels: {exam.q: "$QID"}
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: false
YAML
fi
if ! kc k8s -n expand-demo get pvc data-pvc >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
  namespace: expand-demo
  labels: {exam.q: "$QID"}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: expandable-sc
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata:
  name: data-writer
  namespace: expand-demo
  labels: {exam.q: "$QID"}
spec:
  containers:
  - name: writer
    image: busybox:1.37
    command: ["sh", "-c", "while true; do date >> /data/out.txt; sleep 10; done"]
    volumeMounts:
    - {name: data, mountPath: /data}
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: data-pvc}
YAML
fi
wait_for 90 -- kc k8s -n expand-demo wait --for=jsonpath='{.status.phase}'=Bound pvc/data-pvc --timeout=2s || log "PVC not bound yet"
log "q04 seeded"
