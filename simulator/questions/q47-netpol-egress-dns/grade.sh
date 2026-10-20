set -uo pipefail
source "$LIB/assert.sh"
INTR=$(kc k8s -n egress-dns get svc intruder -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
check_eventually "client resolves and reaches backend by name" 3 30 -- kc k8s -n egress-dns exec deploy/client -- sh -c "wget -qO- -T3 http://backend | grep -q backend"
# negative/constraint checks only count once backend works by name (untouched state must not score)
OK='kc k8s -n egress-dns exec deploy/client -- sh -c "wget -qO- -T3 http://backend | grep -q backend"'
check_sh "client cannot reach intruder by ClusterIP" 1 "$OK && kc k8s -n egress-dns exec deploy/client -- true && ! kc k8s -n egress-dns exec deploy/client -- wget -qO- -T3 http://$INTR"
check_sh "client cannot reach intruder by name" 1 "$OK"' && kc k8s -n egress-dns exec deploy/client -- true && ! kc k8s -n egress-dns exec deploy/client -- wget -qO- -T3 http://intruder'
check_sh "policy still restricts Egress" 1 "$OK"' && kc k8s -n egress-dns get netpol client-egress -o jsonpath="{.spec.policyTypes[*]}" | grep -q Egress'
check_sh "no allow-all egress rule or 0.0.0.0/0" 1 "$OK"' && y=$(kc k8s -n egress-dns get netpol -o yaml) && ! printf "%s" "$y" | grep -Eq "0\.0\.0\.0/0|egress:[[:space:]]*\[\{\}\]|- \{\}"'
