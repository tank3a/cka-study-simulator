#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s expand2
term_sh 'rm -f /home/candidate/q51.txt'
for sc in grow-sc fixed-sc; do
  if ! kc k8s get sc "$sc" >/dev/null 2>&1; then
    kapply k8s -f - <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: $sc
  labels: {exam.q: "$QID"}
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: false
YAML
  fi
done
mk() { # name sc pod
  if ! kc k8s -n expand2 get pvc "$1" >/dev/null 2>&1; then
    kapply k8s -f - <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $1
  namespace: expand2
  labels: {exam.q: "$QID"}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: $2
  resources: {requests: {storage: 500Mi}}
---
apiVersion: v1
kind: Pod
metadata:
  name: $3
  namespace: expand2
  labels: {exam.q: "$QID"}
spec:
  containers:
  - name: app
    image: busybox:1.37
    command: ["sh", "-c", "while true; do date >> /data/out.txt; sleep 10; done"]
    volumeMounts:
    - {name: data, mountPath: /data}
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: $1}
YAML
  fi
}
mk orders-db grow-sc orders
mk archive fixed-sc archiver
wait_for 90 -- kc k8s -n expand2 wait --for=jsonpath='{.status.phase}'=Bound pvc/orders-db --timeout=2s || log "orders-db not bound yet"
log "q51 seeded"
