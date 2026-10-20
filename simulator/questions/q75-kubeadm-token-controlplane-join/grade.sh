set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-cp
check_node_sh "token exists with the description" 1 $N 'kubeadm token list | grep "^0a1b2c.0123456789abcdef" | grep -q "second control plane"'
check_node_sh "token TTL is at most 45 minutes" 1 $N 'kubeadm token list | awk "\$1==\"0a1b2c.0123456789abcdef\"{print \$2}" | grep -Eq "^([1-3]?[0-9]|4[0-5])m"'
check "bootstrap-token secret exists" 1 -- kc ek8s -n kube-system get secret bootstrap-token-0a1b2c
check "kubeadm-certs secret was uploaded" 1 -- kc ek8s -n kube-system get secret kubeadm-certs
check_node_sh "join command has token and CA hash" 1 $N 'J=$(tr "\n" " " < /opt/cka/cp-join.txt | sed "s/\\\\//g"); echo "$J" | grep -q "kubeadm join" && echo "$J" | grep -q -- "--token 0a1b2c.0123456789abcdef" && echo "$J" | grep -Eq -- "--discovery-token-ca-cert-hash sha256:[0-9a-f]{64}"'
check_node_sh "join command is for a control plane node (flag and key)" 1 $N 'J=$(tr "\n" " " < /opt/cka/cp-join.txt | sed "s/\\\\//g"); echo "$J" | grep -q -- "--control-plane" && echo "$J" | grep -Eq -- "--certificate-key [0-9a-f]{64}"'
