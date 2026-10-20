#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=pvc-fix
check_jsonpath "PVC ledger-pvc is Bound" 2 k8s pvc/ledger-pvc -n $NS '{.status.phase}' "Bound"
check_jsonpath "PVC ledger-pvc bound to pv-ledger" 1 k8s pvc/ledger-pvc -n $NS '{.spec.volumeName}' "pv-ledger"
# constraint checks only count once the claim is bound to pv-ledger (the seeded claim already requests 3Gi)
BND='[ "$(kc k8s -n pvc-fix get pvc ledger-pvc -o jsonpath="{.spec.volumeName}")" = pv-ledger ]'
check_sh "PVC ledger-pvc requests 3Gi" 1 "$BND"' && [ "$(kc k8s -n pvc-fix get pvc ledger-pvc -o jsonpath="{.spec.resources.requests.storage}")" = 3Gi ]'
check_sh "PV pv-ledger unchanged (5Gi RWX shared-slow Filesystem)" 1 "$BND"' && [ "$(kc k8s get pv pv-ledger -o jsonpath="{.spec.capacity.storage} {.spec.accessModes[0]} {.spec.storageClassName} {.spec.volumeMode}")" = "5Gi ReadWriteMany shared-slow Filesystem" ]'
check_sh "Deployment still references ledger-pvc" 1 "$BND"' && [ "$(kc k8s -n pvc-fix get deploy ledger-app -o jsonpath="{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}")" = ledger-pvc ]'
check_eventually "Deployment ledger-app Available" 2 120 -- \
  kc k8s -n $NS wait --for=condition=Available deploy/ledger-app --timeout=2s
