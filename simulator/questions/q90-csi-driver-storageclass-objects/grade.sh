set -uo pipefail
source "$LIB/assert.sh"
D=csidriver/hostpath.csi.cka.example.com
S=sc/csi-fast
P=$(kc k8s get sc standard -o "jsonpath={.provisioner}" 2>/dev/null)
if kc k8s get csidriver "$P" >/dev/null 2>&1; then R=yes; else R=no; fi
C=$(kc k8s get csinode k8s-worker -o "jsonpath={.spec.drivers[*].name}" 2>/dev/null | wc -w | tr -d ' ')
check_jsonpath "CSIDriver attachRequired false" 1 k8s $D '{.spec.attachRequired}' false
check_jsonpath "CSIDriver podInfoOnMount true" 1 k8s $D '{.spec.podInfoOnMount}' true
check_sh "CSIDriver lifecycle modes Persistent and Ephemeral" 1 'M=$(kc k8s get csidriver hostpath.csi.cka.example.com -o "jsonpath={.spec.volumeLifecycleModes[*]}"); echo "$M" | grep -qw Persistent && echo "$M" | grep -qw Ephemeral'
check_jsonpath "StorageClass provisioner is the CSI driver" 1 k8s $S '{.provisioner}' hostpath.csi.cka.example.com
check_jsonpath "reclaimPolicy Retain" 1 k8s $S '{.reclaimPolicy}' Retain
check_jsonpath "WaitForFirstConsumer and expansion allowed" 1 k8s $S '{.volumeBindingMode}/{.allowVolumeExpansion}' WaitForFirstConsumer/true
check_jsonpath "parameter type=fast, mount option noatime" 1 k8s $S '{.parameters.type}/{.mountOptions[0]}' fast/noatime
check_sh "csi-fast is not the default class" 1 'kc k8s get sc csi-fast >/dev/null 2>&1 && [ "$(kc k8s get sc csi-fast -o "jsonpath={.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}")" != true ]'
check_sh "PVC data uses csi-fast, 1Gi, RWO" 1 '[ "$(kc k8s -n csi-lab get pvc data -o "jsonpath={.spec.storageClassName}/{.spec.resources.requests.storage}/{.spec.accessModes[0]}")" = csi-fast/1Gi/ReadWriteOnce ]'
check_sh "answers: provisioner and CSIDriver registration" 1 'term_sh "grep -Eq \"^default_storageclass_provisioner=$P\$\" /home/candidate/answers/q90.txt && grep -qx default_provisioner_is_csidriver=$R /home/candidate/answers/q90.txt"'
check_sh "answers: CSINode driver count and PVC phase" 1 'term_sh "grep -qx csinode_driver_count_k8s_worker=$C /home/candidate/answers/q90.txt" && P2=$(kc k8s -n csi-lab get pvc data -o "jsonpath={.status.phase}") && term_sh "grep -qx pvc_data_phase=$P2 /home/candidate/answers/q90.txt"'
