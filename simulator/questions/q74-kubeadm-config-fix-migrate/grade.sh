set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-cp
F=/opt/cka/fixed-init.yaml
check_node_sh "kubeadm config validate passes" 2 $N "kubeadm config validate --config $F"
check_node_sh "apiVersion v1beta4 for kubeadm kinds" 1 $N "grep -q 'apiVersion: kubeadm.k8s.io/v1beta4' $F && ! grep -q 'kubeadm.k8s.io/v1beta3' $F"
check_node_sh "criSocket has unix:// scheme" 1 $N "grep -Eq 'criSocket: *\"?unix:///run/containerd/containerd.sock' $F"
check_node_sh "pod subnet fixed" 1 $N "grep -Eq 'podSubnet: *\"?10.244.0.0/16' $F"
check_node_sh "service subnet kept" 1 $N "grep -Eq 'serviceSubnet: *\"?10.96.0.0/12' $F"
check_node_sh "kubelet cgroupDriver systemd" 1 $N "grep -q 'kind: KubeletConfiguration' $F && grep -Eq 'cgroupDriver: *\"?systemd' $F"
check_node_sh "node name and version kept, original untouched" 1 $N "grep -Eq 'name: *\"?cp1' $F && grep -Eq 'kubernetesVersion: *\"?v1.34.0' $F && cd /opt/cka && sha256sum -c .broken.sha >/dev/null 2>&1"
