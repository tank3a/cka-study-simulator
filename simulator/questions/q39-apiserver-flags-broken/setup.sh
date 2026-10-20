set -uo pipefail
source "$LIB/common.sh"
# marker object proving etcd data is kept (skipped if API is already down)
if kc ek8s get --raw=/readyz >/dev/null 2>&1; then ns_create ek8s apiserver-fix; fi
M=/etc/kubernetes/manifests/kube-apiserver.yaml
# fault 1: etcd CA path. fault 2: wrong secure port (probes + kubeconfig use 6443). Each sed is a no-op once applied.
node_sh ek8s-cp "
sed -i 's#--etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt#--etcd-cafile=/etc/kubernetes/pki/etcd/ca-bundle.crt#' $M
sed -i 's#--secure-port=6443#--secure-port=6444#' $M
exit 0"
