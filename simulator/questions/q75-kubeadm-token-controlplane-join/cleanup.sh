set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp '
kubeadm token delete 0a1b2c.0123456789abcdef >/dev/null 2>&1
KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n kube-system delete secret kubeadm-certs --ignore-not-found >/dev/null 2>&1
rm -f /opt/cka/cp-join.txt
true
'
