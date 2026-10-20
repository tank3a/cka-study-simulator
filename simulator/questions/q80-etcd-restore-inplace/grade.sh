set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-cp
# only count once the old data dir was set aside (untouched state must not score)
restored_ready() { on_node ek8s-cp test -d /var/lib/etcd.old/member && kc ek8s get --raw=/readyz; }
keep_exists() { on_node ek8s-cp test -d /var/lib/etcd.old/member && kc ek8s -n etcd-ip get deploy ledger-keep; }
check_eventually "apiserver healthy after restore" 2 180 -- restored_ready
check_node_sh "new /var/lib/etcd holds restored data" 1 $N '[ -d /var/lib/etcd.old/member ] && [ -d /var/lib/etcd/member ]'
check_node_sh "damaged data kept in /var/lib/etcd.old" 1 $N '[ -d /var/lib/etcd.old/member ]'
check_node_sh "etcd manifest is back and still points at /var/lib/etcd" 2 $N '[ -d /var/lib/etcd.old/member ] && [ -f /etc/kubernetes/manifests/etcd.yaml ] && grep -Eq "path: /var/lib/etcd$" /etc/kubernetes/manifests/etcd.yaml && ! grep -q "etcd-restore\|etcd.old" /etc/kubernetes/manifests/etcd.yaml'
check "ledger-keep exists" 1 -- keep_exists
check_sh "ledger-drop is gone" 1 'on_node ek8s-cp test -d /var/lib/etcd.old/member && kc ek8s get --raw=/readyz >/dev/null 2>&1 && ! kc ek8s -n etcd-ip get deploy ledger-drop >/dev/null 2>&1'
