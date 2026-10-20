# q56 해설: Job completions / parallelism / backoffLimit / activeDeadlineSeconds / TTL

문서 (kubernetes.io 검색창에서 `Jobs` 검색):
- https://kubernetes.io/docs/concepts/workloads/controllers/job/ (`Ctrl+F` `parallelism`, `backoffLimit`, `activeDeadlineSeconds`)
- https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/
- https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/ (restartPolicy)

## 풀이
`kubectl create job` 은 completions/parallelism 플래그가 없으므로 dry-run YAML 을 편집한다.
```bash
kubectl config use-context k8s
kubectl -n job-demo create job batch-calc --image=busybox:1.37 --dry-run=client -o yaml -- sh -c 'echo done-$HOSTNAME' > job.yaml
vim job.yaml
```
`spec` 에 추가 (containers 이름을 `calc` 로, `restartPolicy: Never`):
```yaml
spec:
  completions: 6
  parallelism: 2
  backoffLimit: 3
  activeDeadlineSeconds: 120
  ttlSecondsAfterFinished: 600
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: calc
        image: busybox:1.37
        command: ["sh", "-c", "echo done-$HOSTNAME"]
```
```bash
kubectl apply -f job.yaml
kubectl -n job-demo wait --for=condition=Complete job/batch-calc --timeout=120s
POD=$(kubectl -n job-demo get pods -l job-name=batch-calc -o name | head -1)
kubectl -n job-demo logs $POD > /home/candidate/job-out.txt
```

## 검증
```bash
kubectl -n job-demo get job batch-calc        # COMPLETIONS 6/6
cat /home/candidate/job-out.txt               # done-batch-calc-xxxxx
```
`$HOSTNAME` 은 Pod 이름(`batch-calc-<rand>`)이므로 따옴표 내부에서 쉘이 아니라 컨테이너 쉘이 확장하도록 작은따옴표를 유지.

## 흔한 실수
- `restartPolicy` 를 생략 (Job 은 `Never` 또는 `OnFailure` 필수; 기본 Always 는 거부).
- dry-run 으로 만든 YAML 의 컨테이너 이름이 `batch-calc` 로 남아 있음 (문제는 `calc`).
- 로그 저장 전에 Job 이 끝나기를 기다리지 않음.
- 결과 파일 저장이 TTL(600s)보다 오래 걸려 Pod 가 사라짐 (그 전에 저장).
