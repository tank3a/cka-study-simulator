# q104 - 해설 (controller 비활성화)

## 진단 순서
1. `kubectl -n cm-off get deploy,rs,job,pods` -> RS/Job 객체는 있는데 Pod 이 0개. RS 컨트롤러와 Job 컨트롤러만 일하지 않는다.
2. `kubectl -n cm-off describe rs ...` -> 이벤트 없음 (RS 를 처리하는 컨트롤러가 없다는 뜻. scheduler 문제라면 Pod 은 생겼을 것).
3. `kubectl -n kube-system get pod kube-controller-manager-ek8s-control-plane` -> Running/Ready: 크래시가 아니므로 `crictl logs` 에는 단서가 없다.
4. 실행 인자 확인:
   ```bash
   kubectl -n kube-system get pod kube-controller-manager-ek8s-control-plane -o jsonpath='{.spec.containers[0].command}'
   ssh ek8s-cp; sudo -i
   grep -n controllers /etc/kubernetes/manifests/kube-controller-manager.yaml
   ```
   `--controllers=*,bootstrapsigner,tokencleaner,-replicaset,-job` 발견.

## 수정
```bash
vim /etc/kubernetes/manifests/kube-controller-manager.yaml   # --controllers=*,bootstrapsigner,tokencleaner (kubeadm 기본값)로 복원: ,-replicaset,-job 만 제거
```
kubelet 이 static pod 를 재생성하면 밀려 있던 RS/Job 이 즉시 처리된다.

## 검증
```bash
kubectl -n kube-system get pod kube-controller-manager-ek8s-control-plane
kubectl -n cm-off get deploy,rs,job,pods
```

## 포인트
- "Running 인데 동작이 이상" 이면 로그가 아니라 **인자(command)** 와 설정을 본다. `*,-name` 문법은 나머지는 켜고 name 만 끈다.
- 컴포넌트 구분: RS/Job/Endpoints 가 반응 없음 = controller-manager, Pod 이 Pending = scheduler.

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/ , https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
