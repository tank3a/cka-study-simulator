set -uo pipefail
source "$LIB/assert.sh"
NS=svc-debug
check_sh "Service api has 2 endpoints" 2 '[ $(kc k8s -n svc-debug get endpointslice -l kubernetes.io/service-name=api -o jsonpath="{.items[*].endpoints[*].addresses[0]}" | wc -w) -eq 2 ]'
check_eq "Service api targetPort is 80" 1 "80" -- kc k8s -n "$NS" get svc api -o jsonpath='{.spec.ports[0].targetPort}'
check "http://api works from Pod client" 2 -- kc k8s -n "$NS" exec client -- wget -qO- -T3 http://api
check_eq "Deployment api untouched (generation 1)" 1 "1" -- kc k8s -n "$NS" get deploy api -o jsonpath='{.metadata.generation}'
check_eq "Pod labels untouched" 1 "api backend" -- kc k8s -n "$NS" get deploy api -o jsonpath='{.spec.template.metadata.labels.app} {.spec.template.metadata.labels.tier}'
check_sh "/home/candidate/api-endpoints.txt lists exactly the backing Pod IPs" 2 'exp=$(kc k8s -n svc-debug get pods -l app=api -o jsonpath="{.items[*].status.podIP}" | tr " " "\n" | grep -v "^$" | sort); got=$(term_sh "cat /home/candidate/api-endpoints.txt" | tr -d " \r" | grep -v "^$" | sort); [ -n "$got" ] && [ "$exp" = "$got" ]'
