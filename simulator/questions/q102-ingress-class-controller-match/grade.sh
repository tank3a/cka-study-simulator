set -uo pipefail
source "$LIB/assert.sh"
NS=ing-fix
check_file "class name written" 1 term /home/candidate/ing-class.txt '^[[:space:]]*fix-nginx[[:space:]]*$'
check_eq "shop uses fix-nginx" 2 "fix-nginx" -- kc k8s -n "$NS" get ingress shop -o jsonpath='{.spec.ingressClassName}'
check_eq "legacy uses spec.ingressClassName fix-nginx" 2 "fix-nginx" -- kc k8s -n "$NS" get ingress legacy -o jsonpath='{.spec.ingressClassName}'
check_sh "legacy no longer has the deprecated annotation" 1 '[ -z "$(kc k8s -n ing-fix get ingress legacy -o jsonpath="{.metadata.annotations.kubernetes\.io/ingress\.class}")" ]'
check_eq "rules unchanged (hosts and backends)" 1 "shop.example.com shop legacy.example.com legacy" -- kc k8s -n "$NS" get ingress shop legacy -o jsonpath='{.items[0].spec.rules[0].host} {.items[0].spec.rules[0].http.paths[0].backend.service.name} {.items[1].spec.rules[0].host} {.items[1].spec.rules[0].http.paths[0].backend.service.name}'
check "both IngressClasses still exist" 1 -- kc k8s get ingressclass fix-nginx fix-haproxy
