set -uo pipefail
source "$LIB/assert.sh"
check_sh "k8s-worker is schedulable" 1 '[ -z "$(kc k8s get node k8s-worker -o "jsonpath={.spec.unschedulable}")" ]'
check_sh "k8s-worker2 is unschedulable" 1 '[ "$(kc k8s get node k8s-worker2 -o "jsonpath={.spec.unschedulable}")" = true ]'
check_eventually "only DaemonSet pods remain on k8s-worker2" 2 40 -- bash -c 'P=$(kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context k8s -n drain-lab get pods --field-selector spec.nodeName=k8s-worker2 -o name); ! echo "$P" | grep -v "/agent-" | grep -q .'
# the "web available" / "still exist" checks only count once the maintenance was started (untouched state: web runs 4/4 on k8s-worker2)
check_eventually "web has 4 available replicas" 2 90 -- bash -c '[ "$(kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context k8s get node k8s-worker -o "jsonpath={.spec.unschedulable}")" != true ] && [ "$(kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context k8s -n drain-lab get deploy web -o "jsonpath={.status.availableReplicas}")" = 4 ]'
check_sh "all web pods run on k8s-worker" 1 '[ "$(kc k8s -n drain-lab get pods -l app=web -o "jsonpath={.items[*].spec.nodeName}" | tr " " "\n" | sort -u)" = k8s-worker ]'
check "Deployment web and DaemonSet agent still exist" 1 -- bash -c '[ "$(kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context k8s get node k8s-worker -o "jsonpath={.spec.unschedulable}")" != true ] && kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context k8s -n drain-lab get deploy/web ds/agent'
