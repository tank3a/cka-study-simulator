# q38 - 해설 (kubelet 설정 오류)

## 진단 순서
1. `kubectl get nodes`, `kubectl describe node k8s-worker2` -> Ready=Unknown (kubelet 이 상태를 보고하지 않음).
2. `ssh k8s-node2` -> `sudo -i`
3. `systemctl status kubelet` -> `activating (auto-restart)` 또는 `failed` 로 반복.
4. `journalctl -u kubelet -n 50 --no-pager` (또는 `-f`) -> 첫 에러:
   `unable to load client CA file /etc/kubernetes/pki/ca-bundle.crt: ... no such file or directory`
5. 설정 위치 확인: `systemctl cat kubelet` (drop-in 의 `--config=/var/lib/kubelet/config.yaml`, `EnvironmentFile=/var/lib/kubelet/kubeadm-flags.env`).

## 수정
```bash
grep -n clientCAFile /var/lib/kubelet/config.yaml
ls /etc/kubernetes/pki/ca.crt            # 실제 존재하는 파일
sed -i 's#ca-bundle.crt#ca.crt#' /var/lib/kubelet/config.yaml
systemctl restart kubelet
journalctl -u kubelet -n 30 --no-pager   # 두 번째 에러를 찾는다
```
두 번째 문제: 시작은 되지만 `container runtime is down` / `connection error ... containerd.sck`.
```bash
grep -n containerRuntimeEndpoint /var/lib/kubelet/config.yaml     # unix:///run/containerd/containerd.sck (오타)
ls /run/containerd/containerd.sock                                # 실제 소켓 경로 확인
sed -i 's#containerd.sck#containerd.sock#' /var/lib/kubelet/config.yaml
systemctl restart kubelet
```
(이 노드 이미지에서 runtime endpoint 는 `kubeadm-flags.env` 가 아니라 `/var/lib/kubelet/config.yaml` 의 `containerRuntimeEndpoint` 에 있다. `kubeadm-flags.env` 도 같이 확인할 것.)

## 검증
```bash
systemctl is-active kubelet
exit
kubectl get nodes
kubectl -n kubelet-fix get pod canary
```

## 포인트
- 에러를 하나 고쳤다고 끝이 아니다. 고친 뒤 반드시 `journalctl` 다시 확인.
- 설정 변경 후 `systemctl daemon-reload` (unit/drop-in/EnvironmentFile 변경 시) 와 `restart`.

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/ , https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/
