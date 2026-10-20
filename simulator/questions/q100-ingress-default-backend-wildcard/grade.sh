set -uo pipefail
source "$LIB/assert.sh"
NS=ing-def
check_eq "ingressClassName is nginx" 1 "nginx" -- kc k8s -n "$NS" get ingress portal -o jsonpath='{.spec.ingressClassName}'
check_eq "default backend is fallback:80" 2 "fallback 80" -- kc k8s -n "$NS" get ingress portal -o jsonpath='{.spec.defaultBackend.service.name} {.spec.defaultBackend.service.port.number}'
check_eq "rule host is *.portal.example.com" 1 "*.portal.example.com" -- kc k8s -n "$NS" get ingress portal -o jsonpath='{.spec.rules[0].host}'
check_eq "/api Exact -> api:80" 2 "/api Exact api 80" -- kc k8s -n "$NS" get ingress portal -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/api")].path} {.spec.rules[0].http.paths[?(@.path=="/api")].pathType} {.spec.rules[0].http.paths[?(@.path=="/api")].backend.service.name} {.spec.rules[0].http.paths[?(@.path=="/api")].backend.service.port.number}'
check_eq "/ Prefix -> web:80" 2 "/ Prefix web 80" -- kc k8s -n "$NS" get ingress portal -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/")].path} {.spec.rules[0].http.paths[?(@.path=="/")].pathType} {.spec.rules[0].http.paths[?(@.path=="/")].backend.service.name} {.spec.rules[0].http.paths[?(@.path=="/")].backend.service.port.number}'
# Live check only when an ingress-nginx addon is present
if kc k8s -n ingress-nginx get svc ingress-nginx-controller >/dev/null 2>&1; then
  IP=$(node_ip k8s-worker)
  PORT=$(kc k8s -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}' 2>/dev/null)
  check_http_body "live: unmatched host is served by fallback" 1 "^fallback" -H "Host: nothing.example.org" "http://$IP:${PORT:-0}/"
  check_http_body "live: /api/x under the wildcard host is served by web (Exact)" 1 "^web" -H "Host: eu.portal.example.com" "http://$IP:${PORT:-0}/api/x"
fi
