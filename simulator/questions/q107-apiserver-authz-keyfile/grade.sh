set -uo pipefail
source "$LIB/assert.sh"
M=/etc/kubernetes/manifests/kube-apiserver.yaml
check_node_sh "authorization-mode is Node,RBAC" 2 ek8s-cp "grep -q -- '--authorization-mode=Node,RBAC\$' $M"
check_node_sh "tls-private-key-file points to an existing file" 1 ek8s-cp 'f=$(sed -n "s/.*--tls-private-key-file=//p" '"$M"'); [ -n "$f" ] && [ -f "$f" ]'
check_eventually "apiserver answers /readyz" 2 180 -- kc ek8s get --raw=/readyz
check_eventually "all ek8s nodes Ready" 1 120 -- kc ek8s wait --for=condition=Ready node --all --timeout=5s
check "marker namespace apiserver-fix2 still exists (etcd data kept)" 1 -- kc ek8s get ns apiserver-fix2
check_node_sh "no certificate or key files were deleted/replaced" 1 ek8s-cp "grep -q -- '--authorization-mode=Node,RBAC\$' $M && test -f /etc/kubernetes/pki/apiserver.key && test -f /etc/kubernetes/pki/apiserver.crt && test -f /etc/kubernetes/pki/etcd/ca.crt"
