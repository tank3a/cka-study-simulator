set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp 'mkdir -p /opt/cka; rm -f /opt/cka/fixed-init.yaml'
node_put ek8s-cp /opt/cka/broken-init.yaml <<'YAML'
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  name: cp1
  criSocket: /run/containerd/containerd.sock
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.34.0
networking:
  podSubnet: 10.96.0.0/16
  serviceSubnet: 10.96.0.0/12
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: cgroupfs
YAML
node_sh ek8s-cp 'cd /opt/cka && sha256sum broken-init.yaml > .broken.sha'
