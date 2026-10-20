set -uo pipefail
source "$LIB/assert.sh"
U="system:serviceaccount:ops-system:sync-operator"
export U
check "CRD installed" 1 -- kc k8s get crd syncjobs.sync.cka.example.com
check_sh "can list/watch/update syncjobs in all namespaces" 1 '[ "$(kc k8s auth can-i list syncjobs.sync.cka.example.com -A --as=$U)" = yes ] && [ "$(kc k8s auth can-i update syncjobs.sync.cka.example.com -n default --as=$U)" = yes ]'
check_sh "can patch syncjobs/status and syncjobs/finalizers" 1 '[ "$(kc k8s auth can-i patch syncjobs.sync.cka.example.com --subresource=status -n default --as=$U)" = yes ] && [ "$(kc k8s auth can-i update syncjobs.sync.cka.example.com --subresource=finalizers -n default --as=$U)" = yes ]'
check_sh "can create events" 1 '[ "$(kc k8s auth can-i create events -n ops-system --as=$U)" = yes ]'
check_sh "can use leases in ops-system only" 2 '[ "$(kc k8s auth can-i create leases.coordination.k8s.io -n ops-system --as=$U)" = yes ] && [ "$(kc k8s auth can-i update leases.coordination.k8s.io -n ops-system --as=$U)" = yes ] && [ "$(kc k8s auth can-i create leases.coordination.k8s.io -n default --as=$U)" = no ]'
check_sh "cannot delete syncjobs or create deployments" 1 'kc k8s get clusterrole sync-operator >/dev/null 2>&1 && [ "$(kc k8s auth can-i update syncjobs.sync.cka.example.com -n default --as=$U)" = yes ] && [ "$(kc k8s auth can-i delete syncjobs.sync.cka.example.com -n default --as=$U)" = no ] && [ "$(kc k8s auth can-i create deployments.apps -n ops-system --as=$U)" = no ]'
check_sh "least privilege: no wildcard in the ClusterRole/Role, no cluster-admin" 1 'kc k8s get clusterrole sync-operator >/dev/null 2>&1 && kc k8s -n ops-system get role leader-election >/dev/null 2>&1 && ! kc k8s get clusterrole sync-operator -o yaml | grep -Eq "^[[:space:]]*- .\*.?$" && ! kc k8s -n ops-system get role leader-election -o yaml | grep -Eq "^[[:space:]]*- .\*.?$" && [ "$(kc k8s auth can-i "*" "*" --as=$U)" = no ]'
check_eventually "operator Deployment available with 1 replica" 2 90 -- bash -c '[ "$(kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context k8s -n ops-system get deploy sync-operator -o "jsonpath={.status.availableReplicas}")" = 1 ]'
check_sh "SyncJob nightly created with source/dest" 1 '[ "$(kc k8s -n ops-system get syncjob nightly -o "jsonpath={.spec.source} {.spec.dest}")" = "s3://src s3://dst" ]'
