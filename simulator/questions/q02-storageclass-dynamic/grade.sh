#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=sc-demo
check_jsonpath "StorageClass fast-local provisioner" 1 k8s sc/fast-local '{.provisioner}' "rancher.io/local-path"
check_jsonpath "StorageClass fast-local WaitForFirstConsumer" 1 k8s sc/fast-local '{.volumeBindingMode}' "WaitForFirstConsumer"
check_jsonpath "StorageClass fast-local reclaimPolicy Retain" 1 k8s sc/fast-local '{.reclaimPolicy}' "Retain"
check_jsonpath "StorageClass fast-local allowVolumeExpansion" 1 k8s sc/fast-local '{.allowVolumeExpansion}' "true"
check_sh "StorageClass fast-local is not default" 1 \
  '[ "$(kc k8s get sc fast-local -o jsonpath="{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}")" != "true" ]'
check_jsonpath "PVC web-pvc uses fast-local" 1 k8s pvc/web-pvc -n $NS '{.spec.storageClassName}' "fast-local"
check_eventually "PVC web-pvc is Bound" 2 90 -- \
  kc k8s -n $NS wait --for=jsonpath='{.status.phase}'=Bound pvc/web-pvc --timeout=2s
check_eq "Deployment web mounts web-pvc at /data" 1 "web-pvc /data" -- \
  kc k8s -n $NS get deploy web -o jsonpath='{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName} {.spec.template.spec.containers[0].volumeMounts[0].mountPath}'
check_eventually "Deployment web is Available" 1 90 -- \
  kc k8s -n $NS wait --for=condition=Available deploy/web --timeout=2s
check_sh "StorageClass standard untouched (still default, Delete)" 1 \
  '[ "$(kc k8s get sc standard -o jsonpath="{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}")" = "true" ] && [ "$(kc k8s get sc standard -o jsonpath="{.reclaimPolicy}")" = "Delete" ]'
