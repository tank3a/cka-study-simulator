# q72 풀이

```bash
ssh ek8s-node1
sudo -i

cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay; modprobe br_netfilter        # kind 랩에서는 실패할 수 있음 (파일이 채점 대상)

cat > /etc/sysctl.d/99-k8s-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab            # 부팅 후에도 swap 비활성

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
# 실제 환경이면 systemctl restart containerd (이 랩에서는 재시작하지 않음)

sysctl net.ipv4.ip_forward > /opt/cka/prereq-report.txt
```

참고: 실제 시험에서는 이 값들을 적용한 뒤 `systemctl restart containerd`와 `lsmod | grep br_netfilter`로 확인한다. 이 문제는 kind 노드가 호스트 커널을 공유하므로 파일 내용 위주로 채점한다 (fidelity: low).

문서: https://kubernetes.io/docs/setup/production-environment/container-runtimes/
      https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
