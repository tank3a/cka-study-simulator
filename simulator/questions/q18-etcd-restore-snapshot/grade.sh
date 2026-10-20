set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-cp
# health/keep checks only count once etcd runs from the restored dir (untouched state must not score)
RESTORED='grep -q "path: /var/lib/etcd-restore" /etc/kubernetes/manifests/etcd.yaml || grep -q -- "--data-dir=/var/lib/etcd-restore" /etc/kubernetes/manifests/etcd.yaml'
ready_after() { node_sh ek8s-cp "$RESTORED" && kc ek8s get --raw=/readyz; }
check_eventually "apiserver healthy after restore" 2 180 -- ready_after
check_node_sh "restored data dir exists" 1 $N '[ -d /var/lib/etcd-restore/member ]'
check_node_sh "etcd manifest points at /var/lib/etcd-restore" 2 $N 'grep -q "path: /var/lib/etcd-restore" /etc/kubernetes/manifests/etcd.yaml || grep -q -- "--data-dir=/var/lib/etcd-restore" /etc/kubernetes/manifests/etcd.yaml'
check_node_sh "old data dir kept" 1 $N '( '"$RESTORED"' ) && [ -d /var/lib/etcd/member ]'
check_sh "restore-keep exists" 1 'node_sh ek8s-cp "$RESTORED" && kc ek8s -n etcd-rs get deploy restore-keep'
check_sh "restore-drop is gone (state came from the snapshot)" 1 '! kc ek8s -n etcd-rs get deploy restore-drop >/dev/null 2>&1'
