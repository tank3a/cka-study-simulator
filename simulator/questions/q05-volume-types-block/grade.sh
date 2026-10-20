#!/usr/bin/env bash
set -uo pipefail
source "$LIB/assert.sh"

NS=vol-demo
check_eq "emptyDir shared medium Memory" 1 "Memory" -- \
  kc k8s -n $NS get pod multi-vol -o jsonpath='{.spec.volumes[?(@.name=="shared")].emptyDir.medium}'
check_eq "emptyDir shared sizeLimit 64Mi" 1 "64Mi" -- \
  kc k8s -n $NS get pod multi-vol -o jsonpath='{.spec.volumes[?(@.name=="shared")].emptyDir.sizeLimit}'
check_eq "hostPath volume hostlogs path and type" 1 "/var/log/multi-vol DirectoryOrCreate" -- \
  kc k8s -n $NS get pod multi-vol -o jsonpath='{.spec.volumes[?(@.name=="hostlogs")].hostPath.path} {.spec.volumes[?(@.name=="hostlogs")].hostPath.type}'
check_eq "configMap volume conf uses app-conf" 1 "app-conf" -- \
  kc k8s -n $NS get pod multi-vol -o jsonpath='{.spec.volumes[?(@.name=="conf")].configMap.name}'
check_eq "reader mounts conf read-only at /etc/conf" 1 "/etc/conf true" -- \
  kc k8s -n $NS get pod multi-vol -o jsonpath='{.spec.containers[?(@.name=="reader")].volumeMounts[?(@.name=="conf")].mountPath} {.spec.containers[?(@.name=="reader")].volumeMounts[?(@.name=="conf")].readOnly}'
check_eventually "Pod multi-vol Running with 2/2 containers" 2 90 -- \
  kc k8s -n $NS wait --for=condition=Ready pod/multi-vol --timeout=2s
check_eventually "reader sees data written by writer" 1 40 -- \
  kc k8s -n $NS exec multi-vol -c reader -- grep -q . /shared/out.log
check_jsonpath "raw-pv volumeMode Block" 1 k8s pv/raw-pv '{.spec.volumeMode}' "Block"
check_jsonpath "raw-pv storageClassName raw" 1 k8s pv/raw-pv '{.spec.storageClassName}' "raw"
check_jsonpath "raw-pvc volumeMode Block" 1 k8s pvc/raw-pvc -n $NS '{.spec.volumeMode}' "Block"
check_jsonpath "raw-pvc Bound" 2 k8s pvc/raw-pvc -n $NS '{.status.phase}' "Bound"
