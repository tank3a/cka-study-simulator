set -uo pipefail
source "$LIB/assert.sh"
NS=ing-lab
check_eq "ingressClassName is nginx" 1 "nginx" -- kc k8s -n "$NS" get ingress site -o jsonpath='{.spec.ingressClassName}'
check_eq "host is site.example.com" 1 "site.example.com" -- kc k8s -n "$NS" get ingress site -o jsonpath='{.spec.rules[0].host}'
check_eq "/green Prefix -> green:80" 1 "/green Prefix green 80" -- kc k8s -n "$NS" get ingress site -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/green")].path} {.spec.rules[0].http.paths[?(@.path=="/green")].pathType} {.spec.rules[0].http.paths[?(@.path=="/green")].backend.service.name} {.spec.rules[0].http.paths[?(@.path=="/green")].backend.service.port.number}'
check_eq "/blue Prefix -> blue:80" 1 "/blue Prefix blue 80" -- kc k8s -n "$NS" get ingress site -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/blue")].path} {.spec.rules[0].http.paths[?(@.path=="/blue")].pathType} {.spec.rules[0].http.paths[?(@.path=="/blue")].backend.service.name} {.spec.rules[0].http.paths[?(@.path=="/blue")].backend.service.port.number}'
check_eq "TLS: host site.example.com with Secret site-tls" 2 "site.example.com site-tls" -- kc k8s -n "$NS" get ingress site -o jsonpath='{.spec.tls[0].hosts[0]} {.spec.tls[0].secretName}'
# Live check only when the (retired) ingress-nginx addon is present
if kc k8s -n ingress-nginx get svc ingress-nginx-controller >/dev/null 2>&1; then
  IP=$(node_ip k8s-worker)
  PORT=$(kc k8s -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}' 2>/dev/null)
  check_http_body "live: /green is served by green through the controller" 1 "^green" -H "Host: site.example.com" "http://$IP:${PORT:-0}/green"
  check_http_body "live: /blue is served by blue through the controller" 1 "^blue" -H "Host: site.example.com" "http://$IP:${PORT:-0}/blue"
fi
