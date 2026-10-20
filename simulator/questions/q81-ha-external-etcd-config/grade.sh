set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-cp
F=/opt/cka/ha-external-etcd.yaml
check_node_sh "kubeadm config validate passes" 2 $N "kubeadm config validate --config $F"
check_node_sh "version and controlPlaneEndpoint" 1 $N "grep -Eq 'kubernetesVersion: *\"?v1.34.0' $F && grep -Eq 'controlPlaneEndpoint: *\"?lb.ha.example.com:6443' $F"
check_node_sh "three external etcd endpoints" 1 $N "grep -q 'external:' $F && grep -q 'https://10.0.0.11:2379' $F && grep -q 'https://10.0.0.12:2379' $F && grep -q 'https://10.0.0.13:2379' $F"
check_node_sh "etcd client credentials" 1 $N "grep -Eq 'caFile: *\"?/etc/kubernetes/pki/etcd/ca.crt' $F && grep -Eq 'certFile: *\"?/etc/kubernetes/pki/apiserver-etcd-client.crt' $F && grep -Eq 'keyFile: *\"?/etc/kubernetes/pki/apiserver-etcd-client.key' $F"
check_sh "controller-manager leader is the lease holder node" 1 'H=$(kc ek8s -n kube-system get lease kube-controller-manager -o "jsonpath={.spec.holderIdentity}" | cut -d_ -f1); [ -n "$H" ] && term_sh "grep -qx controller_manager_leader=$H /home/candidate/answers/q81.txt"'
check_file "quorum of 5 members is 3" 1 term /home/candidate/answers/q81.txt '^quorum_5=3$'
check_file "5 members tolerate 2 failures" 1 term /home/candidate/answers/q81.txt '^tolerated_failures_5=2$'
check_file "5 members needed to survive 2 failures" 1 term /home/candidate/answers/q81.txt '^min_members_survive_2=5$'
