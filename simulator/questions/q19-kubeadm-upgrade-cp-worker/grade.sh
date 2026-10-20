set -uo pipefail
source "$LIB/assert.sh"
CP=ik8s-cp; W=ik8s-node1
check_node_sh "cp: kubeadm is v1.35" 1 $CP 'kubeadm version -o short | grep -q "^v1\.35\."'
check_node_sh "cp: kube-apiserver static pod runs v1.35" 3 $CP 'grep -q "kube-apiserver:v1\.35\." /etc/kubernetes/manifests/kube-apiserver.yaml'
check_match "cp: kubelet version in node status is v1.35" 1 '^v1\.35\.' -- kc ik8s get node ik8s-control-plane -o jsonpath='{.status.nodeInfo.kubeletVersion}'
check_sh "cp: node is schedulable (after upgrade)" 1 'kc ik8s get node ik8s-control-plane -o jsonpath="{.status.nodeInfo.kubeletVersion}" | grep -q "^v1\.35\." && [ -z "$(kc ik8s get node ik8s-control-plane -o jsonpath="{.spec.unschedulable}")" ]'
check_node_sh "worker: kubeadm is v1.35" 1 $W 'kubeadm version -o short | grep -q "^v1\.35\."'
check_match "worker: kubelet version in node status is v1.35" 2 '^v1\.35\.' -- kc ik8s get node ik8s-worker -o jsonpath='{.status.nodeInfo.kubeletVersion}'
check_sh "worker: node is schedulable (after upgrade)" 1 'kc ik8s get node ik8s-worker -o jsonpath="{.status.nodeInfo.kubeletVersion}" | grep -q "^v1\.35\." && [ -z "$(kc ik8s get node ik8s-worker -o jsonpath="{.spec.unschedulable}")" ]'
