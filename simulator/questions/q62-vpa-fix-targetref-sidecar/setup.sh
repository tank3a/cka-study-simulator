#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s vpa-b
# Minimal stand-in for the VPA CRD, only if no VPA CRD exists. Shared by q61/q62, deliberately NOT labelled exam.q
# so that resetting one question does not remove it for the other.
if ! kc k8s get crd verticalpodautoscalers.autoscaling.k8s.io >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: verticalpodautoscalers.autoscaling.k8s.io
  labels: {exam.shared: "vpa-stub"}
  annotations: {api-approved.kubernetes.io: "https://github.com/kubernetes/kubernetes/pull/78458"}
spec:
  group: autoscaling.k8s.io
  scope: Namespaced
  names:
    kind: VerticalPodAutoscaler
    listKind: VerticalPodAutoscalerList
    plural: verticalpodautoscalers
    singular: verticalpodautoscaler
    shortNames: [vpa]
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
YAML
  wait_for 30 -- kc k8s wait --for=condition=Established crd/verticalpodautoscalers.autoscaling.k8s.io --timeout=2s || true
fi
if ! kc k8s -n vpa-b get deploy web >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: vpa-b
  labels: {exam.q: "$QID"}
spec:
  replicas: 1
  selector:
    matchLabels: {app: web}
  template:
    metadata:
      labels: {app: web}
    spec:
      containers:
      - name: web
        image: nginx:1.27
        resources:
          requests: {cpu: 50m, memory: 64Mi}
          limits: {cpu: 200m, memory: 128Mi}
      - name: log-sidecar
        image: busybox:1.37
        command: ["sleep", "3600"]
YAML
fi
if ! kc k8s -n vpa-b get vpa.v1.autoscaling.k8s.io web-vpa >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: web-vpa
  namespace: vpa-b
  labels: {exam.q: "$QID"}
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-frontend
  updatePolicy:
    updateMode: "Auto"
YAML
fi
log "q62 seeded"
