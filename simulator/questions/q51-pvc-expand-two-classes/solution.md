# q51 해설: 여러 StorageClass 중 올바른 것만 확장

## 진단
- PVC 의 `storageClassName` 으로 어떤 SC 가 쓰이는지 확인 (`orders-db` -> `grow-sc`, `archive` -> `fixed-sc`).
- 확장 거부 조건: SC 의 `allowVolumeExpansion` 이 true 가 아니면 PVC request 증가가 API 에서 거부된다.
- 함정: 두 SC 모두 expansion=false 이다. `archive` 가 쓰는 `fixed-sc` 는 건드리면 안 된다. 그리고 PVC 는 줄일 수 없다.
문서: https://kubernetes.io/docs/concepts/storage/persistent-volumes/ (`Ctrl+F` `Expanding`)

## 풀이
```bash
kubectl config use-context k8s
kubectl -n expand2 get pvc -o custom-columns=NAME:.metadata.name,SC:.spec.storageClassName,REQ:.spec.resources.requests.storage
kubectl patch sc grow-sc -p '{"allowVolumeExpansion": true}'
kubectl -n expand2 patch pvc orders-db -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'
echo "grow-sc $(kubectl get sc grow-sc -o jsonpath='{.allowVolumeExpansion}')" > /home/candidate/q51.txt
```

## 검증
```bash
kubectl -n expand2 get pvc
kubectl -n expand2 describe pvc orders-db | tail
cat /home/candidate/q51.txt
```
local-path 는 실제 resize 를 하지 않으므로 `status.capacity` 는 그대로일 수 있다 (API 객체만 채점).

## 흔한 실수
- `kubectl patch sc` 를 두 SC 에 모두 적용 (archive 의 SC 는 변경 금지).
- PVC 삭제/재생성 (금지, 데이터 손실).
- 결과 파일을 변경 전 값(`false`)으로 기록.
