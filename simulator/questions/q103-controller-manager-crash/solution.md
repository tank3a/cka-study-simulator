# q103 - 해설 (kube-controller-manager 장애)

## 진단 순서
1. `kubectl -n cm-crash get deploy,rs,pods` -> Deployment 는 `0/3`, **ReplicaSet 자체가 없음**. (Pod 만 Pending 이면 scheduler, RS 가 없거나 RS 가 Pod 을 안 만들면 controller-manager.)
2. `kubectl -n kube-system get pods` -> `kube-controller-manager-ek8s-control-plane` 이 `CrashLoopBackOff`/`Error`.
3. `ssh ek8s-cp` -> `sudo -i` -> `crictl ps -a | grep controller-manager` -> `crictl logs <id>`:
   - 1차: `unknown flag: --use-service-account-credential`
   - 수정 후 2차: `error reading ... sa.key.old: no such file` (서비스어카운트 키 경로 오타)
4. 정상 파일과 비교: `ls /etc/kubernetes/pki/ | grep sa`.

## 수정
```bash
vim /etc/kubernetes/manifests/kube-controller-manager.yaml
#  --use-service-account-credentials=true
#  --service-account-private-key-file=/etc/kubernetes/pki/sa.key
```
저장하면 kubelet 이 static pod 를 자동 재생성한다 (매니페스트 파일은 그대로 두기).

## 검증
```bash
crictl ps | grep controller-manager
exit
kubectl -n kube-system get pod kube-controller-manager-ek8s-control-plane
kubectl -n cm-crash get deploy,rs,pods
```

## 포인트
- controller-manager 가 죽어도 이미 떠 있는 Pod 은 계속 동작한다. 새 RS/Endpoints/Node 상태 갱신이 멈추는 것이 증상.
- 증상별 컴포넌트: Pending + 이벤트 없음 = scheduler, RS 없음 = controller-manager, kubectl 자체 실패 = apiserver.
- 프로세스 오류는 `crictl logs`, 이미지/스케줄 오류는 `describe` 의 Events.

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/ , https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
