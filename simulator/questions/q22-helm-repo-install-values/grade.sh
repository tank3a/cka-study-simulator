set -uo pipefail
source "$LIB/assert.sh"
H="helm --kubeconfig $ADMIN_KUBECONFIG --kube-context k8s -n helm-web"
check_sh "repo cka-charts configured with the right URL" 1 'term_sh "helm repo list" | grep -E "^cka-charts[[:space:]]+http://exam-assets/charts/?[[:space:]]*$"'
check_file "versions file lists both chart versions" 1 term /home/candidate/answers/q22-versions.txt 'cka-charts/cka-web.*1\.1\.0'
check_sh "versions file also lists 1.0.0" 1 'term_sh "grep -E \"cka-web.*1\\.0\\.0\" /home/candidate/answers/q22-versions.txt"'
check_sh "release web is deployed with chart cka-web-1.0.0" 2 "$H list --filter '^web\$' | grep -Eq 'deployed[[:space:]]+cka-web-1\.0\.0'"
check_sh "replicaCount override stored in release values" 1 "$H get values web -o yaml | grep -qx 'replicaCount: 3'"
check_sh "values file applied (NodePort 30082)" 1 "[ \"\$(kc k8s -n helm-web get svc web-cka-web -o jsonpath='{.spec.ports[0].nodePort}')\" = 30082 ]"
check_eventually "3 replicas available" 1 90 -- kc k8s -n helm-web wait --for=jsonpath='{.status.availableReplicas}'=3 deploy/web-cka-web --timeout=1s
