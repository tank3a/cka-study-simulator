# q108 - 해설 (scheduler 인자 오류 + probe 포트)

## 진단 순서
1. `kubectl -n sched-flags get pods` -> Pending, `describe` 의 Events 가 비어 있음 -> scheduler 의심 (q40 과 같은 징후).
2. `kubectl -n kube-system get pods | grep scheduler` -> `CrashLoopBackOff`.
3. `ssh ek8s-cp; sudo -i` -> `crictl ps -a | grep kube-scheduler` -> `crictl logs <id>`:
   `unknown flag: --leader-elct`
4. 오타를 고치면 Pod 이 Running 이지만 **0/1 Ready** 로 남는다 (이번에는 크래시가 아님):
   ```bash
   kubectl -n kube-system describe pod kube-scheduler-ek8s-control-plane | grep -i -A3 'probe failed'
   # Startup probe failed: Get "https://127.0.0.1:10259/livez": connection refused
   grep -n 'secure-port\|10259\|port:' /etc/kubernetes/manifests/kube-scheduler.yaml
   ```
   `--secure-port=10260` 으로 바뀌어 probe(10259)와 어긋남. Pod 이 오래 Ready 가 아니면 결국 재시작된다.

## 수정
```bash
vim /etc/kubernetes/manifests/kube-scheduler.yaml
#  - --leader-elect=true
#  (--secure-port=10260 줄 삭제 또는 10259 로)
```

## 검증
```bash
exit
kubectl -n kube-system get pod kube-scheduler-ek8s-control-plane     # 1/1
kubectl -n sched-flags get pods -o wide
```

## 포인트
- 크래시(로그에 unknown flag) 와 "Running 이지만 Not Ready"(probe 로 describe 의 Events 확인)는 도구가 다르다.
- 스케줄러 문제의 핵심 징후: Pending + 이벤트 없음. 이후 `kube-system` 의 scheduler Pod 상태부터 확인.

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/ , https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
