# q29 풀이 (3개 NetworkPolicy 중 가장 덜 허용하는 것 고르기)

문서: https://kubernetes.io/docs/concepts/services-networking/network-policies/ (섹션 "Behavior of to and from selectors")

```bash
kubectl config use-context k8s
cat /home/candidate/netpol/np-a.yaml /home/candidate/netpol/np-b.yaml /home/candidate/netpol/np-c.yaml
kubectl apply -f /home/candidate/netpol/np-b.yaml
```

판단 기준 (`from` 안의 selector 구조):
- np-a: `namespaceSelector: {}` -> 모든 네임스페이스의 모든 Pod 허용. 너무 넓음.
- np-b: 한 항목 안에 `namespaceSelector` + `podSelector` (AND) -> shop-front 네임스페이스의 role=frontend Pod만 허용. 정답.
- np-c: `-`가 두 개 (OR) -> shop-front의 모든 Pod 또는 shop-back 안의 role=frontend Pod. np-b보다 넓음.

- 들여쓰기/하이픈 하나가 AND와 OR을 가른다. 시험에서는 이 구조 차이를 가장 먼저 본다.
- 검증: `kubectl -n shop-front exec web -- wget -qO- -T3 http://api.shop-back`, batch Pod에서는 timeout.
