set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp '
mkdir -p /opt/cka
rm -f /opt/cka/cert-expiry.txt /opt/cka/join-command.txt /opt/cka/apiserver-sans.txt
kubeadm token list | grep -q "^abcdef.0123456789abcdef" || kubeadm token create abcdef.0123456789abcdef --ttl 24h --description stale-join-token
'
