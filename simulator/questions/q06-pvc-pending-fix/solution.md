# q06 해설: Pending PVC 원인 찾기

## 진단
```bash
kubectl config use-context k8s
kubectl -n pvc-fix get pvc,pod
kubectl -n pvc-fix describe pvc ledger-pvc     # Events 확인 (storageclass "fast" not found 등)
kubectl get pv pv-ledger -o yaml               # 용량, accessModes, storageClassName, volumeMode 확인
```
PV: 5Gi / `ReadWriteMany` / `storageClassName: shared-slow` / `volumeMode: Filesystem`
PVC: 3Gi / `ReadWriteOnce` (불일치) / `storageClassName: fast` (불일치) / `volumeMode: Block` (불일치)

바인딩 조건: storageClassName 동일, PV 의 accessModes 가 PVC 요청 모드를 포함, PV 용량 >= 요청, volumeMode 동일.

## 해결
PVC 의 spec 은 (용량 증가를 제외하고) **불변**이므로 삭제 후 재생성한다. (PV 와 Deployment 는 건드리지 않는다.)
```bash
kubectl -n pvc-fix delete pvc ledger-pvc
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ledger-pvc
  namespace: pvc-fix
spec:
  accessModes: [ReadWriteMany]
  storageClassName: shared-slow
  volumeMode: Filesystem
  resources:
    requests:
      storage: 3Gi
YAML
```
(`kubectl get pvc ledger-pvc -o yaml > pvc.yaml` 로 먼저 백업해서 수정해도 된다. status/uid/resourceVersion 등 서버가 채운 필드는 지우고 apply.)
`kubectl delete pvc` 는 사용 중인 Pod 때문에 `pvc-protection` finalizer 로 멈출 수 있다. 이 문제의 Pod 는 Pending 이라 바로 삭제된다.
Deployment 의 Pod 는 PVC 가 Bound 되면 자동으로 스케줄링된다 (필요하면 `kubectl -n pvc-fix rollout restart deploy/ledger-app` 은 Deployment 를 수정하는 것은 아니지만 필요 없다).

## 검증
```bash
kubectl -n pvc-fix get pvc,pod,deploy
kubectl get pv pv-ledger        # Bound, CLAIM pvc-fix/ledger-pvc
```

## 흔한 실수
- PV 를 수정해서 PVC 에 맞추기 (금지).
- `storageClassName` 만 고치고 accessModes/volumeMode 를 놓침 -> 여전히 Pending. `describe pvc` 는 이유를 잘 알려주지 않으므로 PV 와 PVC 를 나란히 비교한다.
- `storageClassName` 을 지워서 default SC(`standard`)로 동적 프로비저닝되어 pv-ledger 와 무관한 PV 가 생김.
- 문서: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#binding
