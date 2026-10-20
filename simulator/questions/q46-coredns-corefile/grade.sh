set -uo pipefail
source "$LIB/assert.sh"
check_sh "Corefile: kubernetes plugin zone is cluster.local" 1 'kc k8s -n kube-system get cm coredns -o jsonpath="{.data.Corefile}" | grep -Eq "kubernetes[[:space:]]+cluster\.local"'
check_sh "Corefile: forward uses /etc/resolv.conf" 1 'kc k8s -n kube-system get cm coredns -o jsonpath="{.data.Corefile}" | grep -Eq "forward[[:space:]]+\.[[:space:]]+/etc/resolv\.conf"'
check_eventually "client resolves and reaches web by name" 2 90 -- kc k8s -n dns-fix exec deploy/client -- sh -c "wget -qO- -T3 http://web.dns-fix.svc.cluster.local | grep -q hello-web"
check_sh "CoreDNS Deployment fully available" 1 'kc k8s -n kube-system get cm coredns -o jsonpath="{.data.Corefile}" | grep -Eq "kubernetes[[:space:]]+cluster\.local" && [ "$(kc k8s -n kube-system get deploy coredns -o jsonpath="{.status.readyReplicas}")" = "$(kc k8s -n kube-system get deploy coredns -o jsonpath="{.spec.replicas}")" ]'
check_file "nslookup output saved" 1 term /home/candidate/q46/nslookup.txt 'web\.dns-fix\.svc\.cluster\.local'
check_file "nslookup output shows a resolved address" 1 term /home/candidate/q46/nslookup.txt 'Address'
