#!/usr/bin/env bash
set -uo pipefail
source "$LIB/common.sh"

ns_create k8s vpa-a
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
if ! kc k8s -n vpa-a get deploy sizing-target >/dev/null 2>&1; then
  kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sizing-target
  namespace: vpa-a
  labels: {exam.q: "$QID"}
spec:
  replicas: 1
  selector:
    matchLabels: {app: sizing-target}
  template:
    metadata:
      labels: {app: sizing-target}
    spec:
      containers:
      - name: app
        image: registry.k8s.io/pause:3.10
YAML
fi
log "q61 seeded"
