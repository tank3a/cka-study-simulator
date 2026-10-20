#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=data-app
check_jsonpath "PV pv-data capacity is 1Gi" 1 k8s pv/pv-data '{.spec.capacity.storage}' "1Gi"
check_jsonpath "PV pv-data access mode is ReadWriteOnce" 1 k8s pv/pv-data '{.spec.accessModes[0]}' "ReadWriteOnce"
check_jsonpath "PV pv-data uses hostPath /mnt/data-app" 1 k8s pv/pv-data '{.spec.hostPath.path}' "/mnt/data-app"
check_jsonpath "PV pv-data storageClassName is manual" 1 k8s pv/pv-data '{.spec.storageClassName}' "manual"
check_jsonpath "PV pv-data reclaim policy is Retain" 1 k8s pv/pv-data '{.spec.persistentVolumeReclaimPolicy}' "Retain"
check_jsonpath "PVC pvc-data requests 500Mi" 1 k8s pvc/pvc-data -n $NS '{.spec.resources.requests.storage}' "500Mi"
check_jsonpath "PVC pvc-data is Bound" 2 k8s pvc/pvc-data -n $NS '{.status.phase}' "Bound"
check_jsonpath "PVC pvc-data is bound to pv-data" 1 k8s pvc/pvc-data -n $NS '{.spec.volumeName}' "pv-data"
check_eq "Deployment data-app references claim pvc-data" 1 "pvc-data" -- \
  kc k8s -n $NS get deploy data-app -o jsonpath='{.spec.template.spec.volumes[*].persistentVolumeClaim.claimName}'
check_eq "Deployment data-app mounts at /usr/share/nginx/html" 1 "/usr/share/nginx/html" -- \
  kc k8s -n $NS get deploy data-app -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[0].mountPath}'
check_eventually "Deployment data-app is Available" 2 90 -- \
  kc k8s -n $NS wait --for=condition=Available deploy/data-app --timeout=2s
