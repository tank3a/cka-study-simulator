set -uo pipefail
source "$LIB/assert.sh"
check_jsonpath "deployment hello has 2 replicas" k8s deploy/hello -n smoke '{.spec.replicas}' 2
check_eventually "2 replicas available" 1 90 -- bash -c "[ \"\$(kubectl --kubeconfig $ADMIN_KUBECONFIG --context k8s -n smoke get deploy hello -o jsonpath={.status.availableReplicas})\" = 2 ]"
check_file "smoke.txt written" term /home/candidate/smoke.txt '^done$'
