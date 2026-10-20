set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-cp
check_node_sh "snapshot is valid (etcdutl snapshot status)" 2 $N '[ -s /opt/cka/etcd-backup.db ] && etcdutl snapshot status /opt/cka/etcd-backup.db >/dev/null 2>&1'
check_node_sh "snapshot is not trivially small" 1 $N '[ "$(stat -c %s /opt/cka/etcd-backup.db)" -gt 100000 ]'
check_node_sh "snapshot contains the current cluster data" 1 $N 'grep -aq etcd-bk-7f3a91 /opt/cka/etcd-backup.db'
check_file "member count file" 1 $N /opt/cka/etcd-members.txt '^[[:space:]]*1[[:space:]]*$'
# constraint checks only count once a snapshot was taken (untouched state must not score)
check_node_sh "etcd manifest not modified" 1 $N '[ -s /opt/cka/etcd-backup.db ] && grep -q -- "--data-dir=/var/lib/etcd$" /etc/kubernetes/manifests/etcd.yaml'
ready_after() { on_node ek8s-cp test -s /opt/cka/etcd-backup.db && kc ek8s get --raw=/readyz; }
check_eventually "apiserver healthy" 1 30 -- ready_after
