# q65 해설: compute ResourceQuota 와 requests/limits 필수 규칙

문서:
- https://kubernetes.io/docs/concepts/policy/resource-quotas/ (`Ctrl+F` `requests.cpu`)
- https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

## 핵심
quota 에 `requests.cpu`/`limits.cpu` 등 compute 항목이 있으면 그 namespace 의 **모든 새 Pod 는 해당 requests/limits 를 명시**해야 한다
(LimitRange 기본값이 없다면 `must specify limits.cpu` 로 거부). 기존 Pod 는 그대로지만 롤아웃 시 새 ReplicaSet 이 Pod 를 못 만든다.

## 풀이
```bash
kubectl config use-context k8s
kubectl -n quota-a create quota team-quota --hard=pods=4,requests.cpu=1,requests.memory=1Gi,limits.cpu=2,limits.memory=2Gi
kubectl -n quota-a set resources deploy app --requests=cpu=200m,memory=128Mi --limits=cpu=400m,memory=256Mi
kubectl -n quota-a rollout status deploy/app
```
롤링 업데이트 중 최대 4 Pod (3 + surge 1) 이므로 pods=4 한도 안에서 끝난다.

## 검증
```bash
kubectl -n quota-a describe quota team-quota      # Used: pods 3, requests.cpu 600m ...
kubectl -n quota-a get pods
```

## 흔한 실수
- quota 만 만들고 Deployment 를 수정하지 않음 -> 롤아웃/스케일 시 `FailedCreate: must specify limits.cpu ...`.
- 한도 계산 오류: 4 Pod x 400m = 1.6 CPU limits 는 2 이내, requests 4 x 200m = 800m 는 1 이내.
- `--hard` 에 공백을 넣음 (쉼표로 구분, 공백 없음).
