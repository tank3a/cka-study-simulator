set -uo pipefail
source "$LIB/assert.sh"
F=/home/candidate/answers/q21.txt
LEADER=$(kc ek8s -n kube-system get lease kube-scheduler -o jsonpath='{.spec.holderIdentity}' 2>/dev/null | sed 's/_.*//')
EP=$(kc ek8s -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' 2>/dev/null | grep '^controlPlaneEndpoint:' | awk '{print $2}')
MEMBERS=$(on_node ek8s-cp env ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list 2>/dev/null | grep -c .)
check_file "topology=stacked" 1 term $F '^topology=stacked$'
check_file "scheduler_leader" 1 term $F "^scheduler_leader=${LEADER:-ek8s-control-plane}\$"
check_file "control_plane_endpoint" 1 term $F "^control_plane_endpoint=${EP:-ek8s-control-plane:6443}\$"
check_file "etcd_members" 1 term $F "^etcd_members=${MEMBERS:-1}\$"
check_file "min_cp_nodes_for_ha" 1 term $F '^min_cp_nodes_for_ha=3$'
