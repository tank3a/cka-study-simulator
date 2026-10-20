set -uo pipefail
source "$LIB/assert.sh"
check_eventually "big-app: 2 replicas available" 2 90 -- kc k8s -n pending-lab wait --for=condition=Available deploy/big-app --timeout=5s
check_sh "big-app: cpu request <= 250m" 1 'c=$(kc k8s -n pending-lab get deploy big-app -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}"); case "$c" in *m) [ "${c%m}" -le 250 ];; "") true;; *) false;; esac'
check_eventually "reporter pod Running" 1 90 -- kc k8s -n pending-lab wait --for=condition=Ready pod -l app=reporter --timeout=5s
check_sh "reporter runs on k8s-worker" 1 '[ "$(kc k8s -n pending-lab get pod -l app=reporter -o jsonpath="{.items[*].spec.nodeName}" | tr " " "\n" | sort -u)" = k8s-worker ]'
rep_fixed() { [ "$(kc k8s -n pending-lab get pod -l app=reporter -o jsonpath="{.items[*].status.phase}")" = Running ]; }
check_sh "taint exam-reserved still on k8s-worker" 1 'rep_fixed && kc k8s get node k8s-worker -o jsonpath="{.spec.taints[*].key}" | grep -q exam-reserved'
check_sh "reporter nodeSelector unchanged" 1 'rep_fixed && [ "$(kc k8s -n pending-lab get deploy reporter -o jsonpath="{.spec.template.spec.nodeSelector.disktype}")" = ssd ]'
check_eventually "pod db Ready" 1 90 -- kc k8s -n pending-lab wait --for=condition=Ready pod/db --timeout=5s
check_sh "PVC db-data Bound, 1Gi, RWO" 1 '[ "$(kc k8s -n pending-lab get pvc db-data -o jsonpath="{.status.phase}/{.spec.resources.requests.storage}/{.spec.accessModes[0]}")" = "Bound/1Gi/ReadWriteOnce" ]'
