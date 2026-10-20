set -uo pipefail
source "$LIB/assert.sh"
H="helm --kubeconfig $ADMIN_KUBECONFIG --kube-context k8s"
export H
check_sh "repo platform is configured" 1 'term_sh "helm repo list" | grep -q "^platform"'
check_file "answer: chart version 0.2.0" 1 term /home/candidate/answers/q82-version.txt '^0\.2\.0$'
check_file "default values saved" 1 term /home/candidate/answers/q82-values.yaml 'replicaCount: 1'
check_sh "release notes uses chart cka-notes-0.2.0 and is deployed" 2 'L=$($H -n helm-notes list -o json); S=$($H -n helm-notes status notes); echo "$L" | grep -q "\"chart\":\"cka-notes-0.2.0\"" && echo "$S" | grep -q "STATUS: deployed"'
check_jsonpath "replicas overridden to 2" 1 k8s deploy/notes-notes -n helm-notes '{.spec.replicas}' 2
check_eventually "2 replicas available" 1 60 -- bash -c '[ "$(kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context k8s -n helm-notes get deploy notes-notes -o "jsonpath={.status.availableReplicas}")" = 2 ]'
