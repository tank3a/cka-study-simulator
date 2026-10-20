# q57 해설: CronJob 수정 + `--from=cronjob` 수동 실행

문서 (kubernetes.io 검색창에서 `CronJob` 검색):
- https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/ (`Ctrl+F` `concurrencyPolicy`, `startingDeadlineSeconds`)
- https://kubernetes.io/docs/reference/kubectl/quick-reference/ (`Ctrl+F` `cronjob`)

## 진단
```bash
kubectl config use-context k8s
kubectl -n cron-demo get cronjob report -o yaml | head -30
```
`schedule: "0 0 31 2 *"` (2월 31일: 영원히 실행 안 됨) 와 `suspend: true` 가 원인.

## 풀이
```bash
kubectl -n cron-demo patch cronjob report -p '{"spec":{"schedule":"*/5 * * * *","suspend":false,"concurrencyPolicy":"Forbid","successfulJobsHistoryLimit":2,"failedJobsHistoryLimit":1,"startingDeadlineSeconds":60}}'
kubectl -n cron-demo create job report-manual --from=cronjob/report
kubectl -n cron-demo wait --for=condition=Complete job/report-manual --timeout=60s
```

## 검증
```bash
kubectl -n cron-demo get cronjob report
kubectl -n cron-demo get job report-manual -o jsonpath='{.metadata.ownerReferences[0].kind}/{.metadata.ownerReferences[0].name}{"\n"}'
kubectl -n cron-demo logs job/report-manual
```

## 흔한 실수
- `suspend` 만 풀고 schedule 은 그대로 둠.
- CronJob 을 삭제 후 재생성 (문제에서 in place 수정 요구).
- `kubectl create job report-manual --image=...` 로 만들면 ownerReference 가 없다 (`--from=cronjob/report` 사용).
