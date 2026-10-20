set -uo pipefail
source "$LIB/assert.sh"
R=runtimeclass/sandboxed
check_file "handlers file lists runc" 1 term /home/candidate/answers/q91-handlers.txt '^runc$'
check_jsonpath "RuntimeClass handler runc" 1 k8s $R '{.handler}' runc
check_jsonpath "overhead cpu/memory" 2 k8s $R '{.overhead.podFixed.cpu}/{.overhead.podFixed.memory}' 100m/32Mi
check_jsonpath "scheduling nodeSelector runtime=sandbox" 1 k8s $R '{.scheduling.nodeSelector.runtime}' sandbox
check_jsonpath "Deployment sbx uses the RuntimeClass" 1 k8s deploy/sbx -n rc-lab '{.spec.template.spec.runtimeClassName}' sandboxed
check_sh "Deployment itself has no nodeSelector" 1 'kc k8s -n rc-lab get deploy sbx >/dev/null 2>&1 && [ -z "$(kc k8s -n rc-lab get deploy sbx -o "jsonpath={.spec.template.spec.nodeSelector}")" ]'
check_eventually "2 replicas available" 1 90 -- bash -c '[ "$(kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context k8s -n rc-lab get deploy sbx -o "jsonpath={.status.availableReplicas}")" = 2 ]'
# ignore Pods that are still terminating (an earlier ReplicaSet may have placed Pods on k8s-worker2 before the runtimeClassName was added)
live_sbx() { kc k8s -n rc-lab get pods -l app=sbx -o json | jq -r '[.items[]|select(.metadata.deletionTimestamp==null)]'; }
sbx_ok() { local j; j=$(live_sbx); [ "$(echo "$j" | jq -r 'map(.spec.nodeName)|unique|join(",")')" = k8s-worker ] && [ "$(echo "$j" | jq -r '.[0].spec.overhead.cpu')" = 100m ]; }
check_eventually "Pods run on k8s-worker with overhead applied" 2 45 -- sbx_ok
