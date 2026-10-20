set -uo pipefail
source "$LIB/assert.sh"
SA="system:serviceaccount:cr-a:deployer"
check_sh "group ops-audit can list and watch namespaces" 2 '[ "$(kc k8s auth can-i list namespaces --as=u1 --as-group=ops-audit)" = yes ] && [ "$(kc k8s auth can-i watch namespaces --as=u1 --as-group=ops-audit)" = yes ]'
check_sh "a user outside the group cannot list namespaces" 1 'kc k8s get clusterrolebinding ns-lister >/dev/null 2>&1 && [ "$(kc k8s auth can-i list namespaces --as=u1 --as-group=ops-audit)" = yes ] && [ "$(kc k8s auth can-i list namespaces --as=u1)" = no ]'
check_sh "deployer can update configmaps in cr-a" 2 '[ "$(kc k8s auth can-i update configmaps -n cr-a --as=system:serviceaccount:cr-a:deployer)" = yes ] && [ "$(kc k8s auth can-i patch configmaps -n cr-a --as=system:serviceaccount:cr-a:deployer)" = yes ]'
check_sh "deployer cannot edit configmaps in cr-b" 1 'kc k8s -n cr-a get rolebinding cm-editor >/dev/null 2>&1 && [ "$(kc k8s auth can-i update configmaps -n cr-a --as=system:serviceaccount:cr-a:deployer)" = yes ] && [ "$(kc k8s auth can-i update configmaps -n cr-b --as=system:serviceaccount:cr-a:deployer)" = no ]'
check_sh "cm-editor is a RoleBinding to the ClusterRole, no ClusterRoleBinding" 1 'kc k8s get clusterrole cm-editor >/dev/null 2>&1 && kc k8s -n cr-a get rolebinding cm-editor -o "jsonpath={.roleRef.kind}" | grep -qx ClusterRole && ! kc k8s get clusterrolebinding cm-editor >/dev/null 2>&1'
check_sh "user monitor can get /metrics" 2 '[ "$(kc k8s auth can-i get /metrics --as=monitor)" = yes ]'
check_sh "other users cannot get /metrics" 1 '[ "$(kc k8s auth can-i get /metrics --as=monitor)" = yes ] && [ "$(kc k8s auth can-i get /metrics --as=nobody)" = no ]'
check_sh "no wildcard rules in the three ClusterRoles" 1 'kc k8s get clusterrole ns-lister cm-editor metrics-reader >/dev/null 2>&1 && ! kc k8s get clusterrole ns-lister cm-editor metrics-reader -o yaml | grep -Eq "^[[:space:]]*- .\*.?$"'
