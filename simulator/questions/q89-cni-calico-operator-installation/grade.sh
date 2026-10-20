set -uo pipefail
source "$LIB/assert.sh"
P=$(kc ik8s -n kube-system get cm kubeadm-config -o "jsonpath={.data.ClusterConfiguration}" 2>/dev/null | sed -n 's/^ *podSubnet: *//p' | head -1)
export P
check "tigera-operator Deployment exists" 1 -- kc ik8s -n tigera-operator get deploy tigera-operator
check_sh "Installation default uses the cluster pod CIDR" 2 '[ -n "$P" ] && [ "$(kc ik8s get installation default -o "jsonpath={.spec.calicoNetwork.ipPools[0].cidr}")" = "$P" ]'
check_file "edited custom-resources.yaml contains the CIDR" 1 term /home/candidate/manifests/custom-resources.yaml "cidr: *\"?${P:-NOCIDR}"
check_eventually "all nodes Ready" 2 300 -- bash -c '! kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context ik8s get nodes --no-headers | grep -qv " Ready"'
check_eventually "calico-node ready in calico-system" 1 120 -- bash -c 'kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context ik8s -n calico-system rollout status ds/calico-node --timeout=5s'
check_eventually "net-probe has 2 Running pods" 1 120 -- bash -c '[ "$(kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context ik8s -n cni-b get deploy net-probe -o "jsonpath={.status.readyReplicas}")" = 2 ]'
check_sh "pod-to-pod across nodes works" 2 'A=$(kc ik8s -n cni-b get pods -l app=net-probe -o "jsonpath={.items[0].metadata.name}"); IP=$(kc ik8s -n cni-b get pods -l app=net-probe -o "jsonpath={.items[1].status.podIP}"); N=$(kc ik8s -n cni-b get pods -l app=net-probe -o "jsonpath={.items[*].spec.nodeName}" | tr " " "\n" | sort -u | wc -l | tr -d " "); [ -n "$IP" ] && [ "$N" = 2 ] && kc ik8s -n cni-b exec $A -c cli -- wget -qO- -T3 http://$IP >/dev/null'
