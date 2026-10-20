set -uo pipefail
source "$LIB/assert.sh"
NS=svc-nodeport
IP=$(node_ip k8s-worker)
check_eq "web-svc is of type NodePort" 1 "NodePort" -- kc k8s -n "$NS" get svc web-svc -o jsonpath='{.spec.type}'
check_eq "web-svc port 80 -> targetPort 80" 1 "80/80" -- kc k8s -n "$NS" get svc web-svc -o jsonpath='{.spec.ports[0].port}/{.spec.ports[0].targetPort}'
check_eq "web-svc nodePort is 30080" 1 "30080" -- kc k8s -n "$NS" get svc web-svc -o jsonpath='{.spec.ports[0].nodePort}'
check_sh "web-svc has 3 ready endpoints (selector matches the Deployment Pods)" 2 '[ $(kc k8s -n svc-nodeport get endpointslice -l kubernetes.io/service-name=web-svc -o jsonpath="{.items[*].endpoints[*].addresses[0]}" | wc -w) -eq 3 ]'
check_http "NodePort 30080 answers 200 from outside the cluster" 2 200 "http://$IP:30080/"
check_eq "web-internal is ClusterIP 8080 -> 80" 1 "ClusterIP 8080/80" -- kc k8s -n "$NS" get svc web-internal -o jsonpath='{.spec.type} {.spec.ports[0].port}/{.spec.ports[0].targetPort}'
check "web-internal is reachable from Pod tester" 2 -- kc k8s -n "$NS" exec tester -- wget -qO- -T3 http://web-internal:8080
check_eq "Deployment web was not modified" 1 "1" -- kc k8s -n "$NS" get deploy web -o jsonpath='{.metadata.generation}'
