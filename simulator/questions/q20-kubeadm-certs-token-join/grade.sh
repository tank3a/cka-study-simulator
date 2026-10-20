set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-cp
check_file "cert expiry report" 1 $N /opt/cka/cert-expiry.txt 'CERTIFICATE +EXPIRES'
check_node_sh "report contains apiserver and etcd certs" 1 $N 'grep -q "^apiserver " /opt/cka/cert-expiry.txt && grep -q "etcd-server" /opt/cka/cert-expiry.txt'
check_file "join command format" 2 $N /opt/cka/join-command.txt 'kubeadm join .*--token [a-z0-9]{6}\.[a-z0-9]{16}.*--discovery-token-ca-cert-hash sha256:[0-9a-f]{64}'
check_node_sh "join token exists with description and TTL <= 2h" 2 $N 'T=$(grep -o "[a-z0-9]\{6\}\.[a-z0-9]\{16\}" /opt/cka/join-command.txt | head -1); kubeadm token list | grep "^$T" | grep -q "cka worker join" && kubeadm token list | awk -v t="$T" "\$1==t{print \$2}" | grep -Eq "^(2h|1h|[0-9]+m|[0-9]+s)"'
check_node_sh "stale token deleted" 1 $N '! kubeadm token list | grep -q "^abcdef.0123456789abcdef"'
check_file "apiserver SANs file" 1 $N /opt/cka/apiserver-sans.txt 'DNS:kubernetes.default.svc'
