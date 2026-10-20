# q30 풀이 (Egress NetworkPolicy + DNS 허용)

문서: https://kubernetes.io/docs/concepts/services-networking/network-policies/ (예제 "Default deny" 와 egress 섹션)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: client-egress
  namespace: egress-lab
spec:
  podSelector:
    matchLabels:
      app: client
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: egress-data
      podSelector:
        matchLabels:
          app: db
    ports:
    - protocol: TCP
      port: 80
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
```

```bash
kubectl apply -f client-egress.yaml
kubectl -n egress-lab exec client -- wget -qO- -T3 http://db.egress-data      # 성공
kubectl -n egress-lab exec client -- wget -qO- -T3 http://cache.egress-data   # timeout
```

- 함정: DNS egress를 빼면 서비스 이름 조회가 실패한다. UDP만 쓰면 큰 응답(TCP fallback)이 막힌다.
- `namespaceSelector`와 `podSelector`는 같은 `-` 항목 안에 두어야 AND 이다.
- namespace 라벨은 자동으로 붙는 `kubernetes.io/metadata.name` 을 쓴다 (라벨을 새로 붙일 필요 없음).
