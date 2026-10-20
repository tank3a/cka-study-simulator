set -uo pipefail
source "$LIB/assert.sh"
NS=legacy-ing
IP=$(node_ip k8s-worker)
PORT=$(kc k8s -n "$NS" get svc -o jsonpath='{.items[*].spec.ports[?(@.port==80)].nodePort}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -1)
URL="http://$IP:${PORT:-0}"
check_eq "HTTPRoute legacy-route is attached to main-gw" 1 "main-gw" -- kc k8s -n "$NS" get httproute legacy-route -o jsonpath='{.spec.parentRefs[0].name}'
check_eq "hostname is blog.example.com" 1 "blog.example.com" -- kc k8s -n "$NS" get httproute legacy-route -o jsonpath='{.spec.hostnames[0]}'
check_http_body "blog.example.com / is served by blog" 2 "^blog" -H "Host: blog.example.com" "$URL/"
check_http_body "blog.example.com /docs is served by docs" 2 "^docs" -H "Host: blog.example.com" "$URL/docs"
check_http_body "blog.example.com /docs/intro is served by docs (prefix semantics)" 1 "^docs" -H "Host: blog.example.com" "$URL/docs/intro"
# a Gateway without routes answers 404 for every host, so these only count once the route exists
R='kc k8s -n legacy-ing get httproute legacy-route >/dev/null 2>&1'
check_sh "another hostname is not routed (404)" 1 "$R"' && [ "$(term_sh "curl -s -o /dev/null -w %{http_code} --max-time 5 -H \"Host: other.example.com\" '"$URL"'/")" = 404 ]'
check_sh "Ingress legacy has been deleted" 1 '! kc k8s -n legacy-ing get ingress legacy >/dev/null 2>&1'
check_sh "Services blog and docs still exist" 1 "$R"' && kc k8s -n legacy-ing get svc blog docs'
