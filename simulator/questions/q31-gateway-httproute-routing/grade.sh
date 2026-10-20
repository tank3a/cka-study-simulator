set -uo pipefail
source "$LIB/assert.sh"
NS=gw-route
IP=$(node_ip k8s-worker)
# NodePort of the data-plane Service the controller creates for the Gateway (the only Service in the ns with a nodePort)
PORT=$(kc k8s -n "$NS" get svc -o jsonpath='{.items[*].spec.ports[?(@.port==80)].nodePort}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -1)
URL="http://$IP:${PORT:-0}"
check_eq "HTTPRoute app-route is attached to web-gw" 1 "web-gw" -- kc k8s -n "$NS" get httproute app-route -o jsonpath='{.spec.parentRefs[0].name}'
check_eq "HTTPRoute hostname is app.example.com" 1 "app.example.com" -- kc k8s -n "$NS" get httproute app-route -o jsonpath='{.spec.hostnames[0]}'
check_eventually "HTTPRoute is Accepted by the Gateway" 1 30 -- bash -c "[ \"\$(kubectl --kubeconfig \"$ADMIN_KUBECONFIG\" --context k8s -n $NS get httproute app-route -o jsonpath='{.status.parents[0].conditions[?(@.type==\"Accepted\")].status}')\" = True ]"
check_http_body "/v1 is served by app-v1" 1 "^v1" -H "Host: app.example.com" "$URL/v1"
check_http_body "/v2 is served by app-v2" 1 "^v2" -H "Host: app.example.com" "$URL/v2"
check_http_body "/ without header is served by app-v1" 1 "^v1" -H "Host: app.example.com" "$URL/"
check_http_body "/ with X-Env: canary is served by app-v2" 1 "^v2" -H "Host: app.example.com" -H "X-Env: canary" "$URL/"
check_http_body "/v1 with X-Env: canary still goes to app-v1" 1 "^v1" -H "Host: app.example.com" -H "X-Env: canary" "$URL/v1"
