# q04 해설: PVC 확장

## 핵심
1. StorageClass 에 `allowVolumeExpansion: true` 가 없으면 PVC 의 `resources.requests.storage` 증가가 거부된다
   (`only dynamically provisioned pvc can be resized and the storageclass that provisions the pvc must support resize`).
2. StorageClass 의 `allowVolumeExpansion` 은 false -> true 로 바꾸는 것이 허용된다.
3. 그 다음 PVC 의 request 를 늘린다. PVC 는 **줄일 수 없다**.
문서: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#expanding-persistent-volumes-claims (`Ctrl+F` `Expanding`)

## 풀이
```bash
kubectl config use-context k8s
kubectl patch sc expandable-sc -p '{"allowVolumeExpansion": true}'
kubectl -n expand-demo patch pvc data-pvc -p '{"spec":{"resources":{"requests":{"storage":"3Gi"}}}}'
# 또는 kubectl edit pvc data-pvc -n expand-demo  (spec.resources.requests.storage: 3Gi)
```

## 검증
```bash
kubectl get sc expandable-sc -o jsonpath='{.allowVolumeExpansion}{"\n"}'
kubectl -n expand-demo get pvc data-pvc -o jsonpath='{.spec.resources.requests.storage}{"\n"}'
kubectl -n expand-demo describe pvc data-pvc | tail
```
local-path 는 실제 resize 를 하지 않으므로 `status.capacity` 는 그대로일 수 있고, Conditions 에 `FileSystemResizePending` 등이 보일 수 있다 (실제 시험의 CSI 환경에서는 Pod 재시작 후 반영될 수 있음).

## 흔한 실수
- SC 를 먼저 안 고치고 PVC 만 수정 -> 에러.
- PVC 를 삭제 후 재생성 (데이터 손실, 문제에서 금지).
- `kubectl edit pvc` 에서 `status.capacity` 를 고치려는 것 (spec 의 request 가 맞다).
