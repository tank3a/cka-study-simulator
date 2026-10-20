set -uo pipefail
source "$LIB/assert.sh"
check_eq "IngressClass internal uses controller k8s.io/ingress-nginx" 1 "k8s.io/ingress-nginx" -- kc k8s get ingressclass internal -o jsonpath='{.spec.controller}'
check_eq "internal is the default class" 2 "true" -- kc k8s get ingressclass internal -o jsonpath='{.metadata.annotations.ingressclass\.kubernetes\.io/is-default-class}'
check_sh "public is no longer a default class" 2 '[ "$(kc k8s get ingressclass public -o jsonpath="{.metadata.annotations.ingressclass\.kubernetes\.io/is-default-class}")" != "true" ]'
check_sh "IngressClass public still exists" 1 'kc k8s get ingressclass internal >/dev/null 2>&1 && kc k8s get ingressclass public >/dev/null'
check_eq "Ingress docs host and backend" 1 "docs.example.com docs 80" -- kc k8s -n ing-class get ingress docs -o jsonpath='{.spec.rules[0].host} {.spec.rules[0].http.paths[0].backend.service.name} {.spec.rules[0].http.paths[0].backend.service.port.number}'
check_eq "Ingress docs was assigned the class internal" 2 "internal" -- kc k8s -n ing-class get ingress docs -o jsonpath='{.spec.ingressClassName}'
