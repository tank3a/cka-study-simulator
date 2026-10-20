set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp '
mkdir -p /opt/cka
rm -f /opt/cka/cp-join.txt
kubeadm token delete 0a1b2c.0123456789abcdef >/dev/null 2>&1
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl -n kube-system delete secret kubeadm-certs --ignore-not-found >/dev/null 2>&1
true
'
