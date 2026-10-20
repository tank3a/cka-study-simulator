set -uo pipefail
source "$LIB/assert.sh"
NS=egress-lab
check_match "client-egress selects app=client and has policyType Egress" 1 "app=client.*Egress" -- kc k8s -n "$NS" get netpol client-egress -o jsonpath='app={.spec.podSelector.matchLabels.app} {.spec.policyTypes}'
check_eventually "client can reach db.egress-data:80 (DNS + TCP 80 work)" 2 20 -- kc k8s -n "$NS" exec client -- wget -qO- -T3 http://db.egress-data
check_sh "client cannot reach cache.egress-data:80" 2 '! kc k8s -n egress-lab exec client -- wget -qO- -T3 http://cache.egress-data'
check_sh "client cannot reach the Kubernetes API Service (other egress denied)" 1 '! kc k8s -n egress-lab exec client -- wget -qO- -T3 --no-check-certificate https://kubernetes.default.svc'
check_sh "policy has no ipBlock" 1 'y=$(kc k8s -n egress-lab get netpol client-egress -o yaml) && ! printf "%s" "$y" | grep -q ipBlock'
check_sh "DNS rule covers both UDP and TCP port 53" 1 'o=$(kc k8s -n egress-lab get netpol client-egress -o jsonpath="{.spec.egress[*].ports[*].protocol}/{.spec.egress[*].ports[*].port}"); echo "$o" | grep -q UDP && echo "$o" | grep -q TCP && echo "$o" | grep -q 53'
