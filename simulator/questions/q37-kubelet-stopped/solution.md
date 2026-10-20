# q37 - 해설 (kubelet 중지)

## 진단 순서
1. `kubectl get nodes` -> `ek8s-worker` 가 NotReady. 이름을 파일로 저장:
   `kubectl get nodes --no-headers | awk '$2!="Ready"{print $1}' > /home/candidate/q37/notready-node.txt`
2. `kubectl describe node ek8s-worker` -> Conditions 의 Ready 가 `Unknown`, "Kubelet stopped posting node status" 이면 kubelet 이 안 떠 있다는 신호.
3. `ssh ek8s-node1` -> `sudo -i`
4. `systemctl status kubelet` -> `inactive (dead)`, `disabled`. (죽은 이유가 설정 오류라면 `journalctl -u kubelet -n 50 --no-pager` 로 확인. 여기서는 사용자가 stop/disable 한 상태.)

## 수정
```bash
systemctl enable --now kubelet     # enable = 재부팅 유지, --now = 즉시 시작
systemctl status kubelet
```

## 검증
```bash
systemctl is-active kubelet ; systemctl is-enabled kubelet
exit                                # base 로 복귀
kubectl get nodes                  # 30~60초 안에 Ready
```

## 포인트
- `systemctl start` 만 하면 재부팅 후 다시 죽는다 -> 반드시 `enable` 까지.
- NotReady 노드 진단의 첫 3줄: `kubectl describe node`, `systemctl status kubelet`, `journalctl -u kubelet`.

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/ , https://kubernetes.io/docs/concepts/architecture/nodes/
