# q55 해설: StatefulSet partition 카나리 + PVC retention policy

문서 (kubernetes.io 검색창에서 `StatefulSet` -> "Partitioned rolling updates", "PersistentVolumeClaim retention"):
- https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/ (`Ctrl+F` `partition`, `persistentVolumeClaimRetentionPolicy`)
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_rollout/

## 핵심
- `updateStrategy.rollingUpdate.partition: N` -> ordinal >= N 인 Pod 만 새 템플릿으로 업데이트된다. 2 로 두고 이미지를 바꾸면 `web-2` 만 갱신.
- 순서: partition 을 **먼저(또는 같은 patch 로)** 설정한 뒤 이미지를 바꾼다. 이미지만 먼저 바꾸면 모든 Pod 가 롤링된다.
- `persistentVolumeClaimRetentionPolicy: {whenDeleted: Retain, whenScaled: Delete}`.

## 풀이
```bash
kubectl config use-context k8s
kubectl -n sts-upd patch sts web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":2}},"persistentVolumeClaimRetentionPolicy":{"whenDeleted":"Retain","whenScaled":"Delete"}}}'
kubectl -n sts-upd set image sts/web nginx=nginx:1.27-alpine
kubectl -n sts-upd rollout status sts/web --timeout=60s
```

## 검증
```bash
kubectl -n sts-upd get pods -l app=web -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image
kubectl -n sts-upd get sts web -o jsonpath='{.spec.persistentVolumeClaimRetentionPolicy}{"\n"}'
```
(`rollout status` 는 partition 때문에 완료 대기 메시지를 낼 수 있다. `--timeout` 으로 끊는다.)

## 흔한 실수
- 이미지를 먼저 바꿔 전체가 롤링됨 (이 경우 partition 이후에는 되돌릴 수 없다).
- `partition: 3` (replicas 와 같은 값) 이면 아무 Pod 도 갱신되지 않는다.
- `whenScaled` 와 `whenDeleted` 를 반대로 설정.
