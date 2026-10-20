# q59 해설: eviction 을 막는 PDB 수정

문서 (kubernetes.io 검색창에서 `PodDisruptionBudget` 검색, "Unhealthy Pod Eviction Policy"):
- https://kubernetes.io/docs/tasks/run-application/configure-pdb/ (`Ctrl+F` `maxUnavailable`)
- https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/

## 진단
```bash
kubectl config use-context k8s
kubectl -n pdb-b get pdb critical-pdb     # MIN AVAILABLE 2, ALLOWED DISRUPTIONS 0
```
replicas 2 에 `minAvailable: 2` -> 허용 중단 0 -> `kubectl drain` 이 eviction 에서 영원히 재시도.

## 풀이
`minAvailable` 과 `maxUnavailable` 은 동시에 둘 수 없으므로 하나를 null 로 지운다.
```bash
kubectl -n pdb-b patch pdb critical-pdb --type=merge -p '{"spec":{"minAvailable":null,"maxUnavailable":1,"unhealthyPodEvictionPolicy":"AlwaysAllow"}}'
```
(patch 가 거부되는 버전이면 `kubectl -n pdb-b get pdb critical-pdb -o yaml` 로 저장 후 delete & apply 가 아니라 `kubectl edit` 로 필드 교체.)

## 검증
```bash
kubectl -n pdb-b get pdb critical-pdb
kubectl -n pdb-b get pdb critical-pdb -o jsonpath='{.status.disruptionsAllowed}{"\n"}'
```

## 흔한 실수
- `maxUnavailable` 만 추가하고 `minAvailable` 을 지우지 않음 (둘 다 있으면 검증 에러).
- PDB 를 삭제하면 보호가 사라진다 (문제에서 금지).
- `unhealthyPodEvictionPolicy` 오타 (`IfHealthyBudget` 이 기본값, `AlwaysAllow` 로 변경).
