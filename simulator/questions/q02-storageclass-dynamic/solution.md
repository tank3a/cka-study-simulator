# q02 해설: StorageClass 생성 + 동적 프로비저닝

## 핵심
- StorageClass 는 imperative 명령이 없다. 문서의 예제를 복사한다.
- `WaitForFirstConsumer` 이므로 PVC 는 **Pod 가 생성되어 스케줄링될 때까지 Pending** 이다. 이것은 정상이다 (Deployment 를 만들면 Bound 됨).
- `reclaimPolicy` 는 StorageClass 의 최상위 필드 (spec 아님). `allowVolumeExpansion` 도 최상위 필드.

## 풀이
문서: https://kubernetes.io/docs/concepts/storage/storage-classes/ (`Ctrl+F` `allowVolumeExpansion` 또는 `volumeBindingMode`)

```bash
kubectl config use-context k8s
kubectl get sc standard -o yaml        # provisioner, 필드 형태 참고
vim sc.yaml
```
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-local
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```
`is-default-class` annotation 은 넣지 않는다 (넣으면 default 가 둘이 됨).

```bash
kubectl apply -f sc.yaml
vim pvc.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-pvc
  namespace: sc-demo
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: fast-local
  resources:
    requests:
      storage: 1Gi
```
Deployment 뼈대 + volume:
```bash
kubectl -n sc-demo create deploy web --image=nginx:1.27 --dry-run=client -o yaml > d.yaml
```
`d.yaml` 에 `volumeMounts`(mountPath: /data) 와 `volumes`(persistentVolumeClaim.claimName: web-pvc) 추가 후 apply.
(문서: https://kubernetes.io/docs/concepts/storage/persistent-volumes/ 의 "Claims As Volumes")

## 검증
```bash
kubectl get sc
kubectl -n sc-demo get pvc,pod
kubectl get pv      # RECLAIM POLICY 가 Retain 인지 확인
```

## 흔한 실수
- Pod 를 안 만들고 PVC 가 Pending 이라고 당황하기 (WaitForFirstConsumer 는 정상).
- `reclaimPolicy` 를 `parameters` 아래에 넣기.
- `kubectl edit sc standard` 로 default 를 건드리기.
