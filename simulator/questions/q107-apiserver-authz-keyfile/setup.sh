set -uo pipefail
source "$LIB/common.sh"
# marker object proving etcd data is kept (skipped if the API is already down)
if kc ek8s get --raw=/readyz >/dev/null 2>&1; then ns_create ek8s apiserver-fix2; fi
M=/etc/kubernetes/manifests/kube-apiserver.yaml
# fault 1: unknown authorization mode. fault 2: private key path does not exist. Each sed is a no-op once applied.
node_sh ek8s-cp "
sed -i 's#--authorization-mode=Node,RBAC#--authorization-mode=Node,RBCA#' $M
sed -i 's#--tls-private-key-file=/etc/kubernetes/pki/apiserver.key\$#--tls-private-key-file=/etc/kubernetes/pki/apiserver.key.bak#' $M
exit 0"
