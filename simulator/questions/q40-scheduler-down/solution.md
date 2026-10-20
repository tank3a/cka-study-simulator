# q40 - 해설 (kube-scheduler 장애)

## 진단 순서
1. `kubectl -n sched-fix get pods` -> Pending. `kubectl describe pod ...` -> Events 가 비어 있음 (스케줄러가 한 번도 처리하지 않았다는 뜻. "0/3 nodes are available" 류 메시지가 있으면 자원/taint 문제이고, 이벤트가 아예 없으면 스케줄러 자체 문제).
2. `kubectl -n kube-system get pods` -> `kube-scheduler-ek8s-control-plane` 이 `ImagePullBackOff`/`ErrImagePull`.
3. `kubectl -n kube-system describe pod kube-scheduler-ek8s-control-plane` -> `manifest for registry.k8s.io/kube-scheduler:v1.34.99 not found`.
4. `ssh ek8s-cp` -> `sudo -i` -> `grep image: /etc/kubernetes/manifests/kube-*.yaml` 로 apiserver 와 같은 버전 확인.

## 수정 1: 이미지 태그
```bash
grep image: /etc/kubernetes/manifests/kube-apiserver.yaml     # 예: v1.34.0
vim /etc/kubernetes/manifests/kube-scheduler.yaml            # kube-scheduler:v1.34.0
```
kubelet 이 자동으로 pod 를 다시 만든다. 그 뒤에도 CrashLoopBackOff 면:
```bash
crictl ps -a | grep kube-scheduler
crictl logs <id>        # unable to load kubeconfig ... scheduler-conf.yaml: no such file
```
## 수정 2: kubeconfig 경로
```bash
ls /etc/kubernetes/*.conf
sed -i 's#scheduler-conf.yaml#scheduler.conf#' /etc/kubernetes/manifests/kube-scheduler.yaml
```

## 검증
```bash
exit
kubectl -n kube-system get pod kube-scheduler-ek8s-control-plane
kubectl -n sched-fix get pods -o wide
```

## 포인트
- Pending + 이벤트 없음 = scheduler 의심. 먼저 `kubectl -n kube-system get pods`.
- 이미지 에러는 `describe` 의 Events, 프로세스 에러는 `crictl logs`: 증상별로 도구가 다르다.

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/ , https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
