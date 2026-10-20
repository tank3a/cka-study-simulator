# q64 해설: LimitRange 위반으로 ReplicaSet 이 Pod 를 만들지 못하는 경우

문서:
- https://kubernetes.io/docs/concepts/policy/limit-range/
- https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

## 진단
```bash
kubectl config use-context k8s
kubectl -n lr-fix get deploy,rs,pods
kubectl -n lr-fix describe rs -l app=worker | tail -15
kubectl -n lr-fix get events --sort-by=.lastTimestamp | tail
kubectl -n lr-fix describe limitrange container-caps
```
RS 이벤트: `FailedCreate ... maximum cpu usage per Container is 200m, but limit is 500m` 와
`maximum memory usage per Container is 256Mi, but limit is 512Mi`. Pod 가 아예 생성되지 않으므로 `kubectl get pods` 는 비어 있다.

## 풀이
정책(LimitRange)이 아니라 Deployment 를 고친다. 정책을 만족하는 가장 큰 값으로 낮춘다:
```bash
kubectl -n lr-fix set resources deploy worker -c app --limits=cpu=200m,memory=128Mi
kubectl -n lr-fix set resources deploy worker -c cache --limits=cpu=100m,memory=256Mi
kubectl -n lr-fix rollout status deploy/worker
kubectl -n lr-fix apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: worker-data}
spec:
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
EOF
```
(PVC 는 LimitRange 의 `PersistentVolumeClaim` 타입 min 500Mi / max 2Gi 범위 안의 1Gi.)

## 검증
```bash
kubectl -n lr-fix get pods
kubectl -n lr-fix get pvc worker-data
```

## 흔한 실수
- LimitRange 를 삭제/수정 (금지).
- limits 를 모두 제거 (정책에 default 가 없으므로 통과하지만 요구사항 위반).
- `kubectl get pods` 가 비어 있다고 스케줄링 문제로 착각 (RS 이벤트를 봐야 한다).
- 한쪽 컨테이너만 수정.
