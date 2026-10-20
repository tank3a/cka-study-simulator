# q45 - 해설 (NetworkPolicy ingress 체인)

## 진단 순서
```bash
kubectl -n shop-np get pods --show-labels -o wide
kubectl -n shop-np get netpol
kubectl -n shop-np describe netpol allow-web-to-api       # PodSelector: app=api ; From: app=webb  <- 오타
kubectl -n shop-np exec deploy/web -- wget -qO- -T3 http://<api pod IP>      # 시간 초과면 정책 차단
```
핵심: 정책은 **받는 쪽(podSelector)** 에 붙고, `from` 은 보내는 쪽. default-deny 가 있으므로 허용 규칙이 없는 흐름은 모두 막힌다.

## 수정
1. 기존 정책의 오타 수정 (`webb` -> `web`):
```bash
kubectl -n shop-np patch netpol allow-web-to-api --type=json \
  -p='[{"op":"replace","path":"/spec/ingress/0/from/0/podSelector/matchLabels/app","value":"web"}]'
```
2. api -> db 정책 추가:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-api-to-db, namespace: shop-np}
spec:
  podSelector: {matchLabels: {app: db}}
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector: {matchLabels: {app: api}}
    ports: [{protocol: TCP, port: 80}]
```
`from` 에 `podSelector` 만 쓰면 **같은 네임스페이스** 로 한정되므로 다른 네임스페이스(np-other)는 차단된 채 유지.

## 검증
```bash
kubectl -n shop-np exec deploy/web -- wget -qO- -T3 http://$(kubectl -n shop-np get pod -l app=api -o jsonpath='{.items[0].status.podIP}')
kubectl -n shop-np exec deploy/web -- wget -qO- -T3 http://<db IP>      # 실패해야 함
kubectl -n np-other exec probe -- wget -qO- -T3 http://<api IP>         # 실패해야 함
```

## 포인트
- 같은 `from` 항목 안의 `namespaceSelector` + `podSelector` 는 AND, 별도 항목이면 OR.
- 정책을 삭제해서 푸는 것은 정답이 아니다 (조건에 명시).

문서: https://kubernetes.io/docs/concepts/services-networking/network-policies/ , https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/
