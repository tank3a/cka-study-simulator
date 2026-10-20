set -uo pipefail
source "$LIB/assert.sh"
NS=svc-lb2
check_eq "api is of type LoadBalancer" 1 "LoadBalancer" -- kc k8s -n "$NS" get svc api -o jsonpath='{.spec.type}'
check_sh "port 8080 -> 80 and nodePort 30091 preserved" 2 '[ "$(kc k8s -n svc-lb2 get svc api -o jsonpath="{.spec.type}")" = LoadBalancer ] && [ "$(kc k8s -n svc-lb2 get svc api -o jsonpath="{.spec.ports[0].port}/{.spec.ports[0].targetPort}/{.spec.ports[0].nodePort}")" = 8080/80/30091 ]'
check_eq "externalTrafficPolicy is Local" 1 "Local" -- kc k8s -n "$NS" get svc api -o jsonpath='{.spec.externalTrafficPolicy}'
check_sh "Service was edited in place (same UID, not recreated)" 1 '[ "$(kc k8s -n svc-lb2 get svc api -o jsonpath="{.spec.type}")" = LoadBalancer ] && [ "$(kc k8s -n svc-lb2 get svc api -o jsonpath="{.metadata.uid}")" = "$(kc k8s -n svc-lb2 get cm orig -o jsonpath="{.data.uid}")" ]'
HC=$(kc k8s -n "$NS" get svc api -o jsonpath='{.spec.healthCheckNodePort}' 2>/dev/null)
check_sh "healthCheckNodePort has been allocated" 1 '[ -n "'"${HC:-}"'" ] && [ "'"${HC:-0}"'" -gt 0 ]'
check_file "health check port written to the file" 2 term /home/candidate/hc-port.txt "^[[:space:]]*${HC:-none}[[:space:]]*$"
HIP=$(kc k8s -n "$NS" get pod -l app=api -o jsonpath='{.items[0].status.hostIP}' 2>/dev/null)
LBT=$(kc k8s -n "$NS" get svc api -o jsonpath='{.spec.type}' 2>/dev/null)
check_http "nodePort 30091 still answers 200 on a node hosting a Pod (after the change to LoadBalancer)" 1 200 "http://${HIP:-0.0.0.0}:$([ "$LBT" = LoadBalancer ] && echo 30091 || echo 1)/"
