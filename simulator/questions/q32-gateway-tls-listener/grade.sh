set -uo pipefail
source "$LIB/assert.sh"
NS=gw-tls
# the data plane of a freshly created Gateway needs a few seconds
if kc k8s -n "$NS" get gateway shop-gw >/dev/null 2>&1; then wait_for 90 -- kc k8s -n "$NS" rollout status deploy/shop-gw-nginx --timeout=2s >/dev/null 2>&1; fi
IP=$(node_ip k8s-worker)
P80=$(kc k8s -n "$NS" get svc -o jsonpath='{.items[*].spec.ports[?(@.port==80)].nodePort}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -1)
P443=$(kc k8s -n "$NS" get svc -o jsonpath='{.items[*].spec.ports[?(@.port==443)].nodePort}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -1)
check_eq "Gateway uses class nginx" 1 "nginx" -- kc k8s -n "$NS" get gateway shop-gw -o jsonpath='{.spec.gatewayClassName}'
check_eq "listener https: 443 HTTPS shop.example.com" 1 "443 HTTPS shop.example.com" -- kc k8s -n "$NS" get gateway shop-gw -o jsonpath='{.spec.listeners[?(@.name=="https")].port} {.spec.listeners[?(@.name=="https")].protocol} {.spec.listeners[?(@.name=="https")].hostname}'
check_eq "listener https terminates TLS with Secret shop-tls" 2 "Terminate shop-tls" -- kc k8s -n "$NS" get gateway shop-gw -o jsonpath='{.spec.listeners[?(@.name=="https")].tls.mode} {.spec.listeners[?(@.name=="https")].tls.certificateRefs[0].name}'
check_eq "listener http: 80 HTTP" 1 "80 HTTP" -- kc k8s -n "$NS" get gateway shop-gw -o jsonpath='{.spec.listeners[?(@.name=="http")].port} {.spec.listeners[?(@.name=="http")].protocol}'
check_eq "shop-route is attached to listener https" 1 "shop-gw/https" -- kc k8s -n "$NS" get httproute shop-route -o jsonpath='{.spec.parentRefs[0].name}/{.spec.parentRefs[0].sectionName}'
check_eq "shop-redirect is attached to listener http" 1 "shop-gw/http" -- kc k8s -n "$NS" get httproute shop-redirect -o jsonpath='{.spec.parentRefs[0].name}/{.spec.parentRefs[0].sectionName}'
check_http_body "HTTPS request returns the shop page" 2 "^shop" -k --resolve "shop.example.com:${P443:-0}:$IP" "https://shop.example.com:${P443:-0}/"
check_http "HTTP request is redirected with 301" 2 301 -H "Host: shop.example.com" "http://$IP:${P80:-0}/"
