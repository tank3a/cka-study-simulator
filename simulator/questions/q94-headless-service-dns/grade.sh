set -uo pipefail
source "$LIB/assert.sh"
NS=hl-dns
check_eq "db-hl is headless (clusterIP None)" 2 "None" -- kc k8s -n "$NS" get svc db-hl -o jsonpath='{.spec.clusterIP}'
check_eq "db-hl selects app=db" 1 "db" -- kc k8s -n "$NS" get svc db-hl -o jsonpath='{.spec.selector.app}'
check_eventually "db-hl has 3 ready endpoints" 1 60 -- bash -c "[ \$(kubectl --kubeconfig \"$ADMIN_KUBECONFIG\" --context k8s -n $NS get endpointslice -l kubernetes.io/service-name=db-hl -o jsonpath='{.items[*].endpoints[*].addresses[0]}' | wc -w) -eq 3 ]"
check_sh "db-hl resolves to 3 A records from tester" 1 '[ $(kc k8s -n hl-dns exec tester -- nslookup db-hl.hl-dns.svc.cluster.local | grep -Ec "^Address:[[:space:]]+[0-9.]+$") -eq 3 ]'
check_sh "Pod DNS name db-0.db-hl resolves" 1 'kc k8s -n hl-dns exec tester -- nslookup db-0.db-hl.hl-dns.svc.cluster.local >/dev/null 2>&1'
check_file "A record count written" 1 term /home/candidate/hl-count.txt '^[[:space:]]*3[[:space:]]*$'
check_file "db-1 FQDN written" 1 term /home/candidate/hl-pod.txt '^[[:space:]]*db-1\.db-hl\.hl-dns\.svc\.cluster\.local\.?[[:space:]]*$'
check_eq "StatefulSet db was not modified" 1 "1" -- kc k8s -n "$NS" get sts db -o jsonpath='{.metadata.generation}'
