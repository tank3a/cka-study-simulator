set -uo pipefail
source "$LIB/assert.sh"
NS=xn-lab
check_eq "legacy-db is of type ExternalName" 1 "ExternalName" -- kc k8s -n "$NS" get svc legacy-db -o jsonpath='{.spec.type}'
check_match "legacy-db points to backend.xn-shared.svc[.cluster.local]" 2 '^backend\.xn-shared\.svc(\.cluster\.local)?\.?$' -- kc k8s -n "$NS" get svc legacy-db -o jsonpath='{.spec.externalName}'
check_eq "legacy-db has no selector" 1 "" -- kc k8s -n "$NS" get svc legacy-db -o jsonpath='{.spec.selector}'
check_sh "name legacy-db resolves from the Pod" 1 'kc k8s -n xn-lab exec tester -- nslookup legacy-db.xn-lab.svc.cluster.local >/dev/null 2>&1'
check_sh "wget http://legacy-db returns the backend page" 2 'kc k8s -n xn-lab exec tester -- wget -qO- -T3 http://legacy-db | grep -qi "welcome to nginx"'
check_eq "cdn is ExternalName assets.example.org" 1 "ExternalName assets.example.org" -- kc k8s -n "$NS" get svc cdn -o jsonpath='{.spec.type} {.spec.externalName}'
check_eq "Service backend was not modified" 1 "ClusterIP backend 80" -- kc k8s -n xn-shared get svc backend -o jsonpath='{.spec.type} {.spec.selector.app} {.spec.ports[0].port}'
