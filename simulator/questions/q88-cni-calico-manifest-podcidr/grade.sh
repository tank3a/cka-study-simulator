set -uo pipefail
source "$LIB/assert.sh"
P=$(kc ik8s -n kube-system get cm kubeadm-config -o "jsonpath={.data.ClusterConfiguration}" 2>/dev/null | sed -n 's/^ *podSubnet: *//p' | head -1)
export P
CUSTOM=/home/candidate/manifests/calico-custom.yaml
export CUSTOM
check_sh "kubeadm podSubnet could be read and a custom manifest exists" 1 '[ -n "$P" ] && term_sh "test -s $CUSTOM"'
check_sh "custom manifest sets CALICO_IPV4POOL_CIDR to the podSubnet" 2 'term_sh "grep -v \"^ *#\" /home/candidate/manifests/calico-custom.yaml | grep -A1 \"CALICO_IPV4POOL_CIDR\" | grep -q \"value: .*$P\""'
check_sh "original manifest still has the CIDR commented out" 1 'term_sh "test -s $CUSTOM" && ! term_sh "grep -v \"^ *#\" /home/candidate/manifests/calico.yaml | grep -q CALICO_IPV4POOL_CIDR"'
check_eventually "all nodes Ready" 2 240 -- bash -c '! kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context ik8s get nodes --no-headers | grep -qv " Ready"'
check_eventually "calico-node DaemonSet fully ready" 1 120 -- bash -c 'kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context ik8s -n kube-system rollout status ds/calico-node --timeout=5s'
check_eventually "net-probe has 2 Running pods" 1 120 -- bash -c '[ "$(kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context ik8s -n cni-a get deploy net-probe -o "jsonpath={.status.readyReplicas}")" = 2 ]'
check_sh "pod-to-pod across nodes works" 2 'A=$(kc ik8s -n cni-a get pods -l app=net-probe -o "jsonpath={.items[0].metadata.name}"); IP=$(kc ik8s -n cni-a get pods -l app=net-probe -o "jsonpath={.items[1].status.podIP}"); N=$(kc ik8s -n cni-a get pods -l app=net-probe -o "jsonpath={.items[*].spec.nodeName}" | tr " " "\n" | sort -u | wc -l | tr -d " "); [ -n "$IP" ] && [ "$N" = 2 ] && kc ik8s -n cni-a exec $A -c cli -- wget -qO- -T3 http://$IP >/dev/null'
