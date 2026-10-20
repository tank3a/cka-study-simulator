set -uo pipefail
source "$LIB/assert.sh"
NS=shop-back
check "NetworkPolicy allow-api-b (the correct one) is applied" 2 -- kc k8s -n "$NS" get netpol allow-api-b
# negative/constraint checks only count once the candidate applied a policy (untouched state must not score)
B='kc k8s -n shop-back get netpol allow-api-b >/dev/null 2>&1'
check_sh "the over-permissive policies allow-api-a and allow-api-c are NOT applied" 2 "$B"' && ! kc k8s -n shop-back get netpol allow-api-a >/dev/null 2>&1 && ! kc k8s -n shop-back get netpol allow-api-c >/dev/null 2>&1'
check_sh "default-deny-ingress still exists" 1 "$B"' && kc k8s -n shop-back get netpol default-deny-ingress'
check_eventually "web (shop-front, role=frontend) can reach api:80" 2 20 -- kc k8s -n shop-front exec web -- wget -qO- -T3 http://api.shop-back
check_sh "batch (shop-front, role=batch) is blocked" 1 "$B"' && ! kc k8s -n shop-front exec batch -- wget -qO- -T3 http://api.shop-back'
check_sh "intruder (shop-other, even with role=frontend) is blocked" 1 "$B"' && ! kc k8s -n shop-other exec intruder -- wget -qO- -T3 http://api.shop-back'
check_sh "no extra NetworkPolicy was created in shop-back" 1 '[ $(kc k8s -n shop-back get netpol -o name | wc -l) -eq 2 ]'
