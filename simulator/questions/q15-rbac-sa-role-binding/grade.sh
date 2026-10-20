set -uo pipefail
source "$LIB/assert.sh"
export U="system:serviceaccount:rbac-dev:ci-deployer"
check "ServiceAccount ci-deployer exists" 1 -- kc k8s -n rbac-dev get sa ci-deployer
check_jsonpath "RoleBinding binds the ServiceAccount" 1 k8s rolebinding/ci-deployer-binding -n rbac-dev '{.subjects[0].name}' "ci-deployer"
check_jsonpath "RoleBinding references Role deploy-manager" 1 k8s rolebinding/ci-deployer-binding -n rbac-dev '{.roleRef.name}' "deploy-manager"
check_sh "can list/create deployments in rbac-dev" 1 '[ "$(kc k8s auth can-i list deployments.apps -n rbac-dev --as=$U)" = yes ] && [ "$(kc k8s auth can-i create deployments.apps -n rbac-dev --as=$U)" = yes ]'
check_sh "can get pods and pods/log" 1 '[ "$(kc k8s auth can-i get pods -n rbac-dev --as=$U)" = yes ] && [ "$(kc k8s auth can-i get pods --subresource=log -n rbac-dev --as=$U)" = yes ]'
# constraint checks only count once the Role/RoleBinding exist (untouched state must not score)
R='kc k8s -n rbac-dev get role deploy-manager >/dev/null 2>&1 && kc k8s -n rbac-dev get rolebinding ci-deployer-binding >/dev/null 2>&1'
check_sh "cannot delete deployments or read secrets" 1 "$R"' && [ "$(kc k8s auth can-i delete deployments.apps -n rbac-dev --as=$U)" = no ] && [ "$(kc k8s auth can-i get secrets -n rbac-dev --as=$U)" = no ]'
check_sh "no access in rbac-prod" 1 "$R"' && [ "$(kc k8s auth can-i list deployments.apps -n rbac-prod --as=$U)" = no ]'
check_sh "Role has no wildcard" 1 'y=$(kc k8s -n rbac-dev get role deploy-manager -o yaml) && ! printf "%s" "$y" | grep -qF "*"'
check_jsonpath "Deployment pipeline uses ci-deployer" 1 k8s deploy/pipeline -n rbac-dev '{.spec.template.spec.serviceAccountName}' "ci-deployer"
check_file "answer file says no" 1 term /home/candidate/answers/q15-delete.txt '^no$'
