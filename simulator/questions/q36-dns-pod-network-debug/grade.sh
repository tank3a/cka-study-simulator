set -uo pipefail
source "$LIB/assert.sh"
NS=net-debug
check_eventually "broken-client is Running" 1 60 -- kc k8s -n "$NS" wait --for=condition=Ready pod/broken-client --timeout=5s
check "wget http://backend works inside broken-client" 2 -- kc k8s -n "$NS" exec broken-client -- wget -qO- -T3 http://backend
check_sh "broken-client does not use dnsPolicy None / hard-coded nameservers" 1 'p=$(kc k8s -n net-debug get pod broken-client -o jsonpath="{.spec.dnsPolicy}"); n=$(kc k8s -n net-debug get pod broken-client -o jsonpath="{.spec.dnsConfig.nameservers}"); [ "$p" != "None" ] && [ -z "$n" ]'
CIDR=$(kc k8s get node k8s-worker -o jsonpath='{.spec.podCIDR}' 2>/dev/null)
check_sh "podcidr-node1.txt contains the Pod CIDR of k8s-worker" 1 '[ -n "'"$CIDR"'" ] && [ "$(term_sh "cat /home/candidate/podcidr-node1.txt" | tr -d " \r\n")" = "'"$CIDR"'" ]'
check_sh "cni-conf.txt contains a file name that exists in /etc/cni/net.d on k8s-worker" 1 'got=$(term_sh "cat /home/candidate/cni-conf.txt" | tr -d " \r\n"); [ -n "$got" ] && on_node k8s-worker ls /etc/cni/net.d | grep -qx "$got"'
DNSIP=$(kc k8s -n kube-system get svc kube-dns -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
check_sh "dns-ip.txt contains the kube-dns ClusterIP" 1 '[ -n "'"$DNSIP"'" ] && [ "$(term_sh "cat /home/candidate/dns-ip.txt" | tr -d " \r\n")" = "'"$DNSIP"'" ]'
