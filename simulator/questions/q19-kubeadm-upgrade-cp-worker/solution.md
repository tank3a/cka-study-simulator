# q19 풀이 (fidelity: partial, kind에서는 best effort)

```bash
kubectl config use-context ik8s
# --- control plane ---
kubectl drain ik8s-control-plane --ignore-daemonsets --delete-emptydir-data
ssh ik8s-cp; sudo -i
apt-get update
apt-cache madison kubeadm | grep 1.35        # 사용 가능한 패치 버전 확인
apt-get install -y kubeadm='1.35.*'
kubeadm version -o short
kubeadm upgrade plan
kubeadm upgrade apply v1.35.X                # plan이 알려준 버전
apt-get install -y kubelet='1.35.*' kubectl='1.35.*'      # kind: if dpkg asks about /etc/default/kubelet keep the current file (N / Enter), or add -o Dpkg::Options::=--force-confold
systemctl daemon-reload && systemctl restart kubelet
exit; exit
kubectl uncordon ik8s-control-plane

# --- worker ---
kubectl drain ik8s-worker --ignore-daemonsets --delete-emptydir-data
ssh ik8s-node1; sudo -i
apt-get update && apt-get install -y kubeadm='1.35.*'
kubeadm upgrade node                         # worker는 apply가 아니라 node
apt-get install -y kubelet='1.35.*' kubectl='1.35.*'
systemctl daemon-reload && systemctl restart kubelet
exit; exit
kubectl uncordon ik8s-worker
kubectl get nodes
```

핵심: control plane은 `upgrade apply`, 나머지 노드는 `upgrade node`. 순서는 drain -> kubeadm -> upgrade -> kubelet/kubectl -> restart -> uncordon. `drain`은 control plane 노드에도 필요. kind에서 apply가 실패해도 drain/uncordon/kubeadm 버전 체크에서 부분 점수.

문서: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
