# q03 해설: reclaimPolicy 변경 + selector/accessMode 로 PVC 바인딩

## 1) reclaim policy 변경
이미 Bound 된 PV 는 삭제하지 말고 patch 한다 (문서: https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/ ).
```bash
kubectl config use-context k8s
kubectl patch pv legacy-pv -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
kubectl get pv legacy-pv        # RECLAIM POLICY = Retain, STATUS = Bound
```

## 2) selector 로 PV 고르기
`kubectl get pv --show-labels` 로 후보를 본다. `tier=reports` 가 두 개(reports-pv: ROX, scratch-pv: RWO)이므로
**accessMode ReadOnlyMany** 가 맞는 `reports-pv` 만 바인딩된다. StorageClass 없이 쓰려면 `storageClassName: ""` 를
**명시**해야 한다 (필드를 빼면 default StorageClass `standard` 가 붙어서 동적 프로비저닝/Pending 이 된다).
문서: https://kubernetes.io/docs/concepts/storage/persistent-volumes/ → `Ctrl+F` `matchLabels` (PVC 예제의 selector).
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: reports-pvc
  namespace: retain-demo
spec:
  accessModes: [ReadOnlyMany]
  storageClassName: ""
  selector:
    matchLabels:
      tier: reports
  resources:
    requests:
      storage: 2Gi
```

## 3) read-only 마운트 Pod
```bash
kubectl -n retain-demo run reports-reader --image=busybox:1.37 --dry-run=client -o yaml -- sleep 3600 > pod.yaml
```
`volumeMounts` 에 `readOnly: true`, `volumes` 에 `persistentVolumeClaim.claimName: reports-pvc` 추가:
```yaml
    volumeMounts:
    - name: reports
      mountPath: /reports
      readOnly: true
  volumes:
  - name: reports
    persistentVolumeClaim:
      claimName: reports-pvc
```

## 검증
```bash
kubectl get pv,pvc -A | grep -E 'legacy|reports'
kubectl -n retain-demo exec reports-reader -- touch /reports/x   # Read-only file system 에러가 나야 정상
```

## 흔한 실수
- `kubectl delete pv` 후 재생성 (문제에서 금지).
- `storageClassName: ""` 누락.
- PVC accessMode 를 RWO 로 써서 `scratch-pv` 와 맞춰 버림 (그러면 용량/모드는 맞지만 문제 요구와 다름).
- `readOnly` 를 volumes 의 persistentVolumeClaim 아래에만 두기 (이 문제는 container volumeMount 의 readOnly 를 채점).
