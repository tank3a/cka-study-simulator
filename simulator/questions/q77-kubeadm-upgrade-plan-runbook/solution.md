# q77 풀이

```bash
ssh ek8s-cp; sudo -i
# 1) 업그레이드 가능 버전 확인 (읽기 전용)
kubeadm upgrade plan | tee /opt/cka/upgrade-plan.txt

# 2) drain dry-run: 노드는 변하지 않는다
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl drain ek8s-worker --ignore-daemonsets --delete-emptydir-data --dry-run=server | tee /opt/cka/drain-dryrun.txt
# 출력 예: node/ek8s-worker cordoned (server dry run)

# 3) worker 업그레이드 절차 (실행하지 않고 파일에만 기록)
cat > /opt/cka/upgrade-runbook.txt <<'EOF'
kubectl drain ek8s-worker --ignore-daemonsets --delete-emptydir-data
apt-get update && apt-get install -y kubeadm=1.35.x-*
kubeadm upgrade node
apt-get install -y kubelet=1.35.x-* kubectl=1.35.x-*
systemctl daemon-reload
systemctl restart kubelet
kubectl uncordon ek8s-worker
EOF
```

순서가 핵심: control plane은 `kubeadm upgrade apply`, worker는 `kubeadm upgrade node`. drain/uncordon은 control plane(또는 kubectl 가능한 곳)에서, 패키지 설치와 kubelet 재시작은 worker에서 한다. 실제 업그레이드 연습은 q19(ik8s).

문서: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
      https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/
