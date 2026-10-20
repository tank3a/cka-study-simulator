# q58 해설: PodDisruptionBudget (퍼센트 minAvailable)

문서 (kubernetes.io 검색창에서 `PodDisruptionBudget` 검색, "Specifying a PodDisruptionBudget"):
- https://kubernetes.io/docs/tasks/run-application/configure-pdb/ (`Ctrl+F` `minAvailable`)
- https://kubernetes.io/docs/reference/kubectl/quick-reference/ (`Ctrl+F` `pdb`)

## 핵심
- `minAvailable: 75%` 와 replicas 4 -> 최소 3개 유지 -> `ALLOWED DISRUPTIONS` = 1.
- PDB 는 `minAvailable` 과 `maxUnavailable` 중 하나만 설정 가능. 퍼센트는 올림 계산.

## 풀이
```bash
kubectl config use-context k8s
kubectl -n pdb-a create pdb api-pdb --selector=app=api --min-available=75%
kubectl -n pdb-a get pdb api-pdb -o jsonpath='{.status.disruptionsAllowed}{"\n"}' | tee /home/candidate/q58.txt
```

## 검증
```bash
kubectl -n pdb-a get pdb
cat /home/candidate/q58.txt
```

## 흔한 실수
- `--min-available=75` (퍼센트 기호 없음) -> 정수 75개로 해석되어 allowed 0.
- selector 를 Deployment 이름이 아니라 Pod label 로 써야 한다 (`app=api`).
- PDB 생성 직후 status 가 비어 있을 수 있으니 몇 초 뒤 다시 조회.
