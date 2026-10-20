set -uo pipefail
source "$LIB/assert.sh"
check_eventually "web: 2/2 replicas available" 1 90 -- kc k8s -n outage wait --for=condition=Available deploy/web --timeout=5s
check_jsonpath "web: image is nginx:1.27" 1 k8s deploy/web -n outage '{.spec.template.spec.containers[0].image}' nginx:1.27
check_sh "web: 2 ready replicas" 1 '[ "$(kc k8s -n outage get deploy web -o jsonpath="{.status.readyReplicas}")" = 2 ]'
check_eventually "api: DB_HOST visible inside the running container" 2 90 -- kc k8s -n outage exec deploy/api -- sh -c '[ "$DB_HOST" = postgres.outage.svc.cluster.local ]'
check_sh "api: pod not restarting" 1 '[ "$(kc k8s -n outage get pod -l app=api -o jsonpath="{.items[0].status.containerStatuses[0].restartCount}")" -le 1 ]'
check_sh "cache: liveness probe targets port 80 and pod has 0 restarts" 2 '[ "$(kc k8s -n outage get deploy cache -o jsonpath="{.spec.template.spec.containers[0].livenessProbe.httpGet.port}")" = 80 ] && [ "$(kc k8s -n outage get pod -l app=cache -o jsonpath="{.items[0].status.containerStatuses[0].restartCount}")" = 0 ]'
