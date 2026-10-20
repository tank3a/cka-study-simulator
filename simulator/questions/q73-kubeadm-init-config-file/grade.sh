set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-cp
F=/opt/cka/init-config.yaml
check_node_sh "kubeadm config validate passes" 2 $N "kubeadm config validate --config $F"
check_node_sh "version, cluster name, endpoint" 1 $N "grep -Eq 'kubernetesVersion: *\"?v1.34.0' $F && grep -Eq 'clusterName: *\"?prod-eu' $F && grep -Eq 'controlPlaneEndpoint: *\"?cp.prod.example.com:6443' $F"
check_node_sh "pod and service subnets" 1 $N "grep -Eq 'podSubnet: *\"?10.200.0.0/16' $F && grep -Eq 'serviceSubnet: *\"?10.96.0.0/16' $F"
check_node_sh "certSANs" 1 $N "grep -q 'cp.prod.example.com' $F && grep -Eq -- '- *\"?10.0.0.10\"?\$' $F && grep -q certSANs $F"
check_node_sh "node registration (name, criSocket)" 1 $N "grep -Eq 'name: *\"?prod-cp1' $F && grep -Eq 'criSocket: *\"?unix:///run/containerd/containerd.sock' $F"
check_node_sh "advertise address and bind port" 1 $N "grep -Eq 'advertiseAddress: *\"?10.0.0.10' $F && grep -Eq 'bindPort: *6443' $F"
check_node_sh "kubelet cgroupDriver systemd" 1 $N "grep -q 'kind: KubeletConfiguration' $F && grep -Eq 'cgroupDriver: *\"?systemd' $F"
check_file "image list for v1.34.0" 1 $N /opt/cka/init-images.txt 'kube-apiserver:v1\.34\.0'
