set -uo pipefail
source "$LIB/common.sh"
kc ek8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
node_sh ek8s-cp 'rm -f /opt/cka/etcd-backup.db /opt/cka/etcd-members.txt'
