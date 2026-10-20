set -uo pipefail
source "$LIB/assert.sh"
NS=kp-affinity
check_eq "sessionAffinity is ClientIP" 2 "ClientIP" -- kc k8s -n "$NS" get svc sticky -o jsonpath='{.spec.sessionAffinity}'
check_eq "affinity timeout is 600 s" 2 "600" -- kc k8s -n "$NS" get svc sticky -o jsonpath='{.spec.sessionAffinityConfig.clientIP.timeoutSeconds}'
check_sh "Service was edited in place (same UID)" 1 '[ "$(kc k8s -n kp-affinity get svc sticky -o jsonpath="{.metadata.uid}")" = "$(kc k8s -n kp-affinity get cm orig -o jsonpath="{.data.uid}")" ]'
check_eventually "10 requests from tester hit exactly one Pod" 2 30 -- bash -c "n=\$(for i in 1 2 3 4 5 6 7 8 9 10; do kubectl --kubeconfig \"$ADMIN_KUBECONFIG\" --context k8s -n $NS exec tester -- wget -qO- -T3 http://sticky; done | sort -u | grep -c .); [ \"\$n\" -eq 1 ]"
check_file "distinct-Pod count written" 1 term /home/candidate/affinity.txt '^[[:space:]]*1[[:space:]]*$'
check_eq "Deployment sticky was not modified" 1 "1" -- kc k8s -n "$NS" get deploy sticky -o jsonpath='{.metadata.generation}'
