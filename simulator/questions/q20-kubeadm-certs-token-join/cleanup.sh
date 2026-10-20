set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp '
kubeadm token delete abcdef.0123456789abcdef >/dev/null 2>&1
for t in $(kubeadm token list 2>/dev/null | grep "cka worker join" | cut -d" " -f1); do kubeadm token delete "$t" >/dev/null 2>&1; done
rm -f /opt/cka/cert-expiry.txt /opt/cka/join-command.txt /opt/cka/apiserver-sans.txt
'
