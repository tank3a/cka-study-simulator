# q73 풀이

```bash
ssh ek8s-cp; sudo -i
cat > /opt/cka/init-config.yaml <<'EOF'
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.0.0.10
  bindPort: 6443
nodeRegistration:
  name: prod-cp1
  criSocket: unix:///run/containerd/containerd.sock
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: v1.34.0
clusterName: prod-eu
controlPlaneEndpoint: cp.prod.example.com:6443
networking:
  podSubnet: 10.200.0.0/16
  serviceSubnet: 10.96.0.0/16
apiServer:
  certSANs:
  - cp.prod.example.com
  - 10.0.0.10
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF

kubeadm config validate --config /opt/cka/init-config.yaml
kubeadm config images list --config /opt/cka/init-config.yaml > /opt/cka/init-images.txt
# (실제 부트스트랩은: kubeadm init --config /opt/cka/init-config.yaml --upload-certs)
```

팁: 처음부터 쓰기 어려우면 `kubeadm config print init-defaults --component-configs KubeletConfiguration`로 뼈대를 만든다. `kubeadm init --config`와 `--pod-network-cidr` 같은 플래그는 함께 쓰지 말고 한 방식만 쓴다.

문서: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
