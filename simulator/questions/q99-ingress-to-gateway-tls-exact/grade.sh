set -uo pipefail
source "$LIB/assert.sh"
NS=mig-tls
IP=$(node_ip k8s-worker)
P=$(kc k8s -n "$NS" get svc -o jsonpath='{.items[*].spec.ports[?(@.port==443)].nodePort}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -1)
R=(-k --resolve "store.example.com:${P:-0}:$IP")
U="https://store.example.com:${P:-0}"
check_eq "Gateway store-gw: class nginx, https 443 HTTPS store.example.com" 1 "nginx https 443 HTTPS store.example.com" -- kc k8s -n "$NS" get gateway store-gw -o jsonpath='{.spec.gatewayClassName} {.spec.listeners[0].name} {.spec.listeners[0].port} {.spec.listeners[0].protocol} {.spec.listeners[0].hostname}'
check_eq "listener terminates TLS with store-tls" 1 "Terminate store-tls" -- kc k8s -n "$NS" get gateway store-gw -o jsonpath='{.spec.listeners[0].tls.mode} {.spec.listeners[0].tls.certificateRefs[0].name}'
check_eq "store-route is attached to store-gw/https" 1 "store-gw/https" -- kc k8s -n "$NS" get httproute store-route -o jsonpath='{.spec.parentRefs[0].name}/{.spec.parentRefs[0].sectionName}'
check_http_body "/ is served by web" 1 "^web" "${R[@]}" "$U/"
check_http_body "/other is served by web (Prefix /)" 1 "^web" "${R[@]}" "$U/other"
check_http_body "/api is served by api (Exact)" 2 "^api" "${R[@]}" "$U/api"
check_http_body "/api/v2 is served by web, not api (Exact semantics)" 2 "^web" "${R[@]}" "$U/api/v2"
check_sh "Ingress store has been deleted" 1 '! kc k8s -n mig-tls get ingress store >/dev/null 2>&1'
check "Services web and api and Secret store-tls still exist" 1 -- kc k8s -n "$NS" get svc/web svc/api secret/store-tls
