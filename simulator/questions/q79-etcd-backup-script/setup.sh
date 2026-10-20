set -uo pipefail
source "$LIB/common.sh"
wait_for 120 -- kc ek8s get --raw=/readyz
node_sh ek8s-cp 'mkdir -p /opt/cka; rm -rf /opt/cka/etcd-backup.sh /opt/cka/backups /opt/cka/etcd-snap-status.json /opt/cka/etcd-endpoint-status.txt'
