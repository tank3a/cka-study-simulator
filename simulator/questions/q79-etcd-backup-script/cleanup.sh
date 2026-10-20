set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp 'rm -rf /opt/cka/etcd-backup.sh /opt/cka/backups /opt/cka/etcd-snap-status.json /opt/cka/etcd-endpoint-status.txt /tmp/grade-snap.db'
