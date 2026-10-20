# q43 - 해설 (Pending 원인 3가지)

## 진단 순서
```bash
kubectl -n pending-lab get pods,pvc
kubectl -n pending-lab describe pod <pod>      # Events 의 FailedScheduling 메시지가 핵심
kubectl get nodes --show-labels ; kubectl describe node k8s-worker | grep -i -A2 taint
kubectl get sc
```
1. **big-app**: `0/3 nodes are available: 3 Insufficient cpu` -> requests.cpu 48 이 노드 allocatable 보다 큼.
   `kubectl describe node | grep -A6 Allocatable` 로 확인.
   수정: `kubectl -n pending-lab set resources deploy big-app --requests=cpu=100m,memory=64Mi`
2. **reporter**: `node(s) didn't match Pod's node affinity/selector` + `node(s) had untolerated taint {exam-reserved: q43}`.
   nodeSelector(disktype=ssd)를 만족하는 노드가 없고, k8s-worker 에는 taint 가 있음.
   수정: 노드 라벨 추가 + toleration 추가 (Deployment 를 고치면 pod 가 재생성됨; taint 는 제거하지 않는다).
   ```bash
   kubectl label node k8s-worker disktype=ssd
   kubectl -n pending-lab patch deploy reporter --type=merge -p \
   '{"spec":{"template":{"spec":{"tolerations":[{"key":"exam-reserved","operator":"Equal","value":"q43","effect":"NoSchedule"}]}}}}'
   ```
3. **db**: pod 는 `pod has unbound immediate PersistentVolumeClaims` 또는 PVC Pending.
   `kubectl -n pending-lab describe pvc db-data` -> `storageclass.storage.k8s.io "fast-ssd" not found`.
   PVC spec 은 변경 불가 -> 방법 A: 이름이 `fast-ssd` 인 StorageClass 생성(provisioner rancher.io/local-path, WaitForFirstConsumer),
   방법 B: pod 와 PVC 를 삭제하고 `storageClassName: standard` 로 다시 생성 (이름/크기/모드 유지).
   (A 예: `kubectl get sc standard -o yaml` 을 참고해 name 을 fast-ssd 로 바꾼 StorageClass 를 작성)
   방법 B 예: `kubectl -n pending-lab delete pod db pvc/db-data` 후 `storageClassName: standard` 로 재생성.

## 검증
```bash
kubectl -n pending-lab get pods -o wide ; kubectl -n pending-lab get pvc
kubectl get node k8s-worker -o jsonpath='{.spec.taints}'
```

## 포인트
- Pending 이면 항상 `describe pod` 의 FailedScheduling 메시지를 읽는다 (Insufficient / didn't match selector / untolerated taint / unbound PVC).
- 실행 중인 pod 의 nodeSelector/tolerations 는 수정할 수 없고, Deployment template 을 수정하면 새 pod 가 생긴다.

문서: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ , https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ , https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ , https://kubernetes.io/docs/concepts/storage/persistent-volumes/
