set -uo pipefail
source "$LIB/assert.sh"
H="helm --kubeconfig $ADMIN_KUBECONFIG --kube-context k8s -n helm-app"
F=/home/candidate/answers/preview.yaml
check_sh "release shop is deployed" 1 "$H list --filter '^shop\$' | grep -q deployed"
check_sh "history shows a rollback to revision 1" 2 "$H history shop | grep -q 'Rollback to 1'"
check_sh "history has an upgrade after the rollback (>= 4 revisions)" 1 "[ \"\$($H history shop | grep -c -E '^[0-9]+')\" -ge 4 ]"
check_jsonpath "image is the working one" 1 k8s deploy/shop-cka-app -n helm-app '{.spec.template.spec.containers[0].image}' "nginx:1.27"
check_sh "values kept: replicaCount=3 and message=prod (reuse-values)" 2 "$H get values shop -o yaml | grep -qx 'replicaCount: 3' && $H get values shop -o yaml | grep -qx 'message: prod'"
check_eventually "3 pods running" 1 90 -- kc k8s -n helm-app wait --for=jsonpath='{.status.availableReplicas}'=3 deploy/shop-cka-app --timeout=1s
check_file "rendered manifest has preview Deployment with 4 replicas" 1 term $F 'name: preview-cka-app'
check_sh "rendered with preview values and nothing installed" 1 "term_sh 'grep -q \"replicas: 4\" $F && grep -q \"nodePort: 30099\" $F && grep -q \"preview build\" $F' && ! $H status preview >/dev/null 2>&1"
