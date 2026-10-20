set -uo pipefail
source "$LIB/common.sh"
ns_create ek8s etcd-bk
kc ek8s -n etcd-bk create configmap backup-marker --from-literal=marker=etcd-bk-7f3a91 --dry-run=client -o yaml | kapply ek8s -f -
label_q ek8s configmap backup-marker -n etcd-bk
node_sh ek8s-cp 'mkdir -p /opt/cka && rm -f /opt/cka/etcd-backup.db /opt/cka/etcd-members.txt'
