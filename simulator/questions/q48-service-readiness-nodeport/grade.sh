set -uo pipefail
source "$LIB/assert.sh"
check_eventually "Deployment portal has 2 ready replicas" 2 90 -- kc k8s -n svc-ready wait --for=jsonpath='{.status.readyReplicas}'=2 deploy/portal --timeout=5s
check_sh "Service has 2 ready endpoints" 1 '[ "$(kc k8s -n svc-ready get endpoints portal -o jsonpath="{.subsets[0].addresses[*].ip}" | wc -w)" -ge 2 ]'
check_http "NodePort answers 200 on k8s-worker" 1 200 -m 4 "http://$(node_ip k8s-worker):30048/"
check_http "NodePort answers 200 on k8s-worker2" 1 200 -m 4 "http://$(node_ip k8s-worker2):30048/"
# constraint checks only count once the Service has endpoints (untouched state must not score)
OK='[ "$(kc k8s -n svc-ready get endpoints portal -o jsonpath="{.subsets[0].addresses[*].ip}" | wc -w)" -ge 2 ]'
check_sh "nodePort unchanged" 1 "$OK"' && [ "$(kc k8s -n svc-ready get svc portal -o jsonpath="{.spec.ports[0].nodePort}")" = 30048 ]'
check_sh "readiness probe still present" 1 "$OK"' && [ -n "$(kc k8s -n svc-ready get deploy portal -o jsonpath="{.spec.template.spec.containers[0].readinessProbe}")" ]'
check_sh "targetPort is a name, not a number" 1 "$OK"' && kc k8s -n svc-ready get svc portal -o jsonpath="{.spec.ports[0].targetPort}" | grep -Eq "^[A-Za-z]"'
