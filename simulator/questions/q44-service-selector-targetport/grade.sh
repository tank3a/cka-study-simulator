set -uo pipefail
source "$LIB/assert.sh"
API_IP=$(kc k8s -n svc-lab get svc shop-api -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
WEB_IP=$(kc k8s -n svc-lab get svc shop-web -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
check_sh "shop-api has endpoints" 1 '[ -n "$(kc k8s -n svc-lab get endpoints shop-api -o jsonpath="{.subsets[*].addresses[*].ip}")" ]'
check_sh "shop-web has endpoints" 1 '[ -n "$(kc k8s -n svc-lab get endpoints shop-web -o jsonpath="{.subsets[*].addresses[*].ip}")" ]'
check_eventually "shop-api answers with nginx page" 2 30 -- kc k8s -n svc-lab exec deploy/tester -- sh -c "wget -qO- -T3 http://$API_IP | grep -q 'Welcome to nginx'"
check_eventually "shop-web answers 'shop-web'" 2 30 -- kc k8s -n svc-lab exec deploy/tester -- sh -c "wget -qO- -T3 http://$WEB_IP | grep -q shop-web"
# constraint checks only count once shop-api was repaired (untouched state must not score)
F='[ -n "$(kc k8s -n svc-lab get endpoints shop-api -o jsonpath="{.subsets[*].addresses[*].ip}")" ]'
check_sh "Deployments untouched (generation 1)" 1 "$F"' && [ "$(kc k8s -n svc-lab get deploy shop-api shop-web -o jsonpath="{.items[*].metadata.generation}")" = "1 1" ]'
check_sh "Services still ClusterIP port 80" 1 "$F"' && [ "$(kc k8s -n svc-lab get svc shop-api shop-web -o jsonpath="{.items[*].spec.type}/{.items[*].spec.ports[0].port}")" = "ClusterIP ClusterIP/80 80" ]'
