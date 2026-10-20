set -uo pipefail
source "$LIB/assert.sh"
NS=gw-multi
CTRL=$(kc k8s get gatewayclass nginx -o jsonpath='{.spec.controllerName}' 2>/dev/null)
IP=$(node_ip k8s-worker)
PORT=$(kc k8s -n "$NS" get svc -o jsonpath='{.items[*].spec.ports[?(@.port==80)].nodePort}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -1)
check_sh "controllerName written to the file" 1 '[ -n "'"$CTRL"'" ] && term_sh "cat /home/candidate/gwc-controller.txt" | tr -d " \r\n" | grep -qx "'"$CTRL"'"'
check_eq "Gateway shared-gw: class nginx, listener http 80 HTTP *.apps.example.com" 2 "nginx http 80 HTTP *.apps.example.com" -- kc k8s -n "$NS" get gateway shared-gw -o jsonpath='{.spec.gatewayClassName} {.spec.listeners[0].name} {.spec.listeners[0].port} {.spec.listeners[0].protocol} {.spec.listeners[0].hostname}'
check_eq "allowedRoutes uses a namespace selector on shared-gw-access=true" 2 "Selector true" -- kc k8s -n "$NS" get gateway shared-gw -o jsonpath='{.spec.listeners[0].allowedRoutes.namespaces.from} {.spec.listeners[0].allowedRoutes.namespaces.selector.matchLabels.shared-gw-access}'
check_eq "namespace gw-team-a is labelled" 1 "true" -- kc k8s get ns gw-team-a -o jsonpath='{.metadata.labels.shared-gw-access}'
check_eq "a-route has hostname a.apps.example.com and backend app-a" 1 "a.apps.example.com app-a" -- kc k8s -n gw-team-a get httproute a-route -o jsonpath='{.spec.hostnames[0]} {.spec.rules[0].backendRefs[0].name}'
check_eventually "a.apps.example.com is served by app-a" 2 40 -- bash -c "curl_out=\$(docker exec -u candidate exam-term curl -s --max-time 5 -H 'Host: a.apps.example.com' 'http://$IP:${PORT:-0}/'); printf '%s' \"\$curl_out\" | grep -q '^app-a'"
check_eventually "b-route is NOT accepted by the Gateway" 1 40 -- bash -c "kubectl --kubeconfig \"$ADMIN_KUBECONFIG\" --context k8s -n gw-multi get gateway shared-gw >/dev/null 2>&1 && [ \"\$(kubectl --kubeconfig \"$ADMIN_KUBECONFIG\" --context k8s -n gw-team-b get httproute b-route -o jsonpath='{.status.parents[0].conditions[?(@.type==\"Accepted\")].status}')\" = False ]"
check_sh "namespace gw-team-b is not labelled" 1 '[ -z "$(kc k8s get ns gw-team-b -o jsonpath="{.metadata.labels.shared-gw-access}")" ]'
