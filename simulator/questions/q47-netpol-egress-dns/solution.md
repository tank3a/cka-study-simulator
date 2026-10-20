# q47 - 해설 (Egress 정책으로 DNS 차단)

## 진단 순서
```bash
kubectl -n egress-dns get netpol
kubectl -n egress-dns describe netpol client-egress          # Egress: backend:80 만 허용 -> kube-dns(53) 없음
kubectl -n egress-dns exec deploy/client -- nslookup backend  # timeout / bad address
kubectl -n egress-dns exec deploy/client -- wget -qO- -T3 http://<backend pod IP>   # IP 로는 됨 -> DNS 만 막힘
kubectl get pods -n kube-system -l k8s-app=kube-dns --show-labels
kubectl get ns kube-system --show-labels                      # kubernetes.io/metadata.name=kube-system
```
Egress 정책은 DNS(UDP/TCP 53) 도 명시적으로 허용해야 한다.

## 수정
`client-egress` 에 규칙 추가 (`kubectl edit netpol client-egress -n egress-dns`):
```yaml
  egress:
  - to:
    - podSelector:
        matchLabels: {app: backend}
    ports:
    - {protocol: TCP, port: 80}
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: kube-system}
      podSelector:
        matchLabels: {k8s-app: kube-dns}
    ports:
    - {protocol: UDP, port: 53}
    - {protocol: TCP, port: 53}
```
(`namespaceSelector` 와 `podSelector` 를 같은 `to` 항목에 두면 AND.)

## 검증
```bash
kubectl -n egress-dns exec deploy/client -- wget -qO- -T3 http://backend        # backend
kubectl -n egress-dns exec deploy/client -- wget -qO- -T3 http://intruder       # 실패해야 함
```

## 포인트
- "IP 로는 되는데 이름은 안 됨" = DNS(53) 경로 차단. 
- 모든 egress 를 열지 말고 kube-system 의 kube-dns 만 연다.

문서: https://kubernetes.io/docs/concepts/services-networking/network-policies/ , https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
