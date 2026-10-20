set -uo pipefail
source "$LIB/assert.sh"
API=$(kc k8s -n shop-np get pod -l app=api -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
DB=$(kc k8s -n shop-np get pod -l app=db -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
# IPs are used so that the grade does not depend on cluster DNS
check_eventually "web -> api allowed" 2 30 -- kc k8s -n shop-np exec deploy/web -- wget -qO- -T3 "http://$API"
check_eventually "api -> db allowed" 2 30 -- kc k8s -n shop-np exec deploy/api -- wget -qO- -T3 "http://$DB"
# negative/constraint checks only count once api -> db works (untouched state must not score)
OK="kc k8s -n shop-np exec deploy/api -- wget -qO- -T3 http://$DB >/dev/null"
check_sh "web -> db still blocked" 1 "$OK && kc k8s -n shop-np exec deploy/web -- true && ! kc k8s -n shop-np exec deploy/web -- wget -qO- -T3 http://$DB"
check_sh "other namespace -> api blocked" 1 "$OK && kc k8s -n np-other exec pod/probe -- true && ! kc k8s -n np-other exec pod/probe -- wget -qO- -T3 http://$API"
check_sh "other namespace -> db blocked" 1 "$OK && kc k8s -n np-other exec pod/probe -- true && ! kc k8s -n np-other exec pod/probe -- wget -qO- -T3 http://$DB"
check_sh "deny-all-ingress policy still exists" 1 "$OK && kc k8s -n shop-np get networkpolicy deny-all-ingress"
check_sh "Deployment labels untouched" 1 "$OK"' && [ "$(kc k8s -n shop-np get deploy web api db -o jsonpath="{.items[*].spec.template.metadata.labels.app}")" = "web api db" ]'
