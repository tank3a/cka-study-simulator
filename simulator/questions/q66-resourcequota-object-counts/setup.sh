#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s quota-b
kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: existing
  namespace: quota-b
  labels: {exam.q: "$QID"}
spec:
  replicas: 1
  selector:
    matchLabels: {app: existing}
  template:
    metadata:
      labels: {app: existing}
    spec:
      containers:
      - name: pause
        image: registry.k8s.io/pause:3.10
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-a
  namespace: quota-b
  labels: {exam.q: "$QID"}
spec:
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
YAML
dep() { # name
term_put /home/candidate/quota-tests/$1.yaml <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $1
  labels: {exam.q: "$QID"}
spec:
  replicas: 1
  selector:
    matchLabels: {app: $1}
  template:
    metadata:
      labels: {app: $1}
    spec:
      containers:
      - name: pause
        image: registry.k8s.io/pause:3.10
YAML
}
dep a-deploy-extra
dep b-deploy-third
term_put /home/candidate/quota-tests/c-svc-nodeport.yaml <<YAML
apiVersion: v1
kind: Service
metadata:
  name: np-svc
  labels: {exam.q: "$QID"}
spec:
  type: NodePort
  selector: {app: existing}
  ports:
  - {port: 80}
YAML
term_put /home/candidate/quota-tests/d-pvc-big.yaml <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-big
  labels: {exam.q: "$QID"}
spec:
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 5Gi}}
YAML
term_put /home/candidate/quota-tests/e-pvc-small.yaml <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-small
  labels: {exam.q: "$QID"}
spec:
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
YAML
log "q66 seeded"
