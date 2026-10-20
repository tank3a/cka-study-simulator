set -uo pipefail
source "$LIB/assert.sh"
NS=svc-lb
check_eq "shop-lb is of type LoadBalancer" 1 "LoadBalancer" -- kc k8s -n "$NS" get svc shop-lb -o jsonpath='{.spec.type}'
check_eq "port 80 -> targetPort 80" 1 "80/80" -- kc k8s -n "$NS" get svc shop-lb -o jsonpath='{.spec.ports[0].port}/{.spec.ports[0].targetPort}'
check_eq "loadBalancerSourceRanges is 10.0.0.0/8" 2 "10.0.0.0/8" -- kc k8s -n "$NS" get svc shop-lb -o jsonpath='{.spec.loadBalancerSourceRanges[0]}'
check_eq "externalTrafficPolicy is Local" 2 "Local" -- kc k8s -n "$NS" get svc shop-lb -o jsonpath='{.spec.externalTrafficPolicy}'
check_sh "shop-lb has 2 endpoints (selector matches the Deployment Pods)" 1 '[ $(kc k8s -n svc-lb get endpointslice -l kubernetes.io/service-name=shop-lb -o jsonpath="{.items[*].endpoints[*].addresses[0]}" | wc -w) -eq 2 ]'
NP=$(kc k8s -n "$NS" get svc shop-lb -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
check_file "nodePort number written to the file" 1 term /home/candidate/shop-lb-nodeport.txt "^[[:space:]]*${NP:-none}[[:space:]]*$"
# With the Local policy only a node that runs a shop Pod answers; use the node of the first Pod.
HIP=$(kc k8s -n "$NS" get pod -l app=shop -o jsonpath='{.items[0].status.hostIP}' 2>/dev/null)
check_http "nodePort answers 200 on a node that hosts a Pod" 1 200 "http://${HIP:-0.0.0.0}:${NP:-0}/"
check_eq "Deployment shop was not modified" 1 "1" -- kc k8s -n "$NS" get deploy shop -o jsonpath='{.metadata.generation}'
