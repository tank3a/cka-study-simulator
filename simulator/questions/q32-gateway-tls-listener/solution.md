# q32 풀이 (Gateway HTTPS listener + HTTP->HTTPS 리다이렉트)

문서: https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/ (HTTPRoute),
TLS 예제는 https://kubernetes.io/docs/concepts/services-networking/gateway/ 와 gateway-api.sigs.k8s.io 에서
"TLS" 로 검색 (listener의 `tls.certificateRefs`). Gateway TLS 예제는 찾기 어렵다는 후기가 많으니 필드 이름을 외워 둘 것.
(https://gateway-api.sigs.k8s.io/api-types/httproute/ 는 404)

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shop-gw
  namespace: gw-tls
spec:
  gatewayClassName: nginx
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    hostname: shop.example.com
    tls:
      mode: Terminate
      certificateRefs:
      - {kind: Secret, name: shop-tls}
    allowedRoutes: {namespaces: {from: Same}}
  - name: http
    port: 80
    protocol: HTTP
    hostname: shop.example.com
    allowedRoutes: {namespaces: {from: Same}}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: shop-route, namespace: gw-tls}
spec:
  parentRefs:
  - {name: shop-gw, sectionName: https}
  hostnames: [shop.example.com]
  rules:
  - backendRefs:
    - {name: shop, port: 80}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: shop-redirect, namespace: gw-tls}
spec:
  parentRefs:
  - {name: shop-gw, sectionName: http}
  hostnames: [shop.example.com]
  rules:
  - filters:
    - type: RequestRedirect
      requestRedirect:
        scheme: https
        statusCode: 301
```

- 검증: `kubectl -n gw-tls get gateway,httproute`, `kubectl -n gw-tls describe gateway shop-gw` (listener Programmed/Accepted).
- 테스트: `curl -k --resolve shop.example.com:<nodePort443>:<node-ip> https://shop.example.com:<nodePort443>/`
- `sectionName` 을 빼면 두 listener 모두에 붙어 리다이렉트 루프/충돌이 생길 수 있다.
