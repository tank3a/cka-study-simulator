#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=retain-demo
check_jsonpath "legacy-pv reclaim policy is Retain" 2 k8s pv/legacy-pv '{.spec.persistentVolumeReclaimPolicy}' "Retain"
check_jsonpath "legacy-pvc still Bound to legacy-pv" 1 k8s pvc/legacy-pvc -n $NS '{.spec.volumeName}' "legacy-pv"
check_jsonpath "reports-pvc requests 2Gi" 1 k8s pvc/reports-pvc -n $NS '{.spec.resources.requests.storage}' "2Gi"
check_jsonpath "reports-pvc access mode ReadOnlyMany" 1 k8s pvc/reports-pvc -n $NS '{.spec.accessModes[0]}' "ReadOnlyMany"
check_jsonpath "reports-pvc has no StorageClass (empty string)" 1 k8s pvc/reports-pvc -n $NS '{.spec.storageClassName}' ""
check_jsonpath "reports-pvc bound to reports-pv" 2 k8s pvc/reports-pvc -n $NS '{.spec.volumeName}' "reports-pv"
check_eq "Pod reports-reader mounts reports-pvc" 1 "reports-pvc" -- \
  kc k8s -n $NS get pod reports-reader -o jsonpath='{.spec.volumes[*].persistentVolumeClaim.claimName}'
check_eq "Pod reports-reader mounts /reports readOnly" 1 "/reports true" -- \
  kc k8s -n $NS get pod reports-reader -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath} {.spec.containers[0].volumeMounts[0].readOnly}'
check_eventually "Pod reports-reader is Ready" 1 90 -- \
  kc k8s -n $NS wait --for=condition=Ready pod/reports-reader --timeout=2s
