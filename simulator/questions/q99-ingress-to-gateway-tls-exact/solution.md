# q99 풀이 (TLS Ingress -> Gateway + HTTPRoute, Exact 경로)

문서: https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/

```bash
kubectl config use-context k8s
kubectl -n mig-tls get ingress store -o yaml     # host, secretName, path/pathType 확인

kubectl -n mig-tls apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: store-gw}
spec:
  gatewayClassName: nginx
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    hostname: store.example.com
    tls:
      mode: Terminate
      certificateRefs: [{name: store-tls}]
    allowedRoutes: {namespaces: {from: Same}}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: store-route}
spec:
  parentRefs: [{name: store-gw, sectionName: https}]
  hostnames: [store.example.com]
  rules:
  - matches: [{path: {type: Exact, value: /api}}]
    backendRefs: [{name: api, port: 80}]
  - matches: [{path: {type: PathPrefix, value: /}}]
    backendRefs: [{name: web, port: 80}]
YAML

kubectl -n mig-tls delete ingress store
```

- Ingress `pathType: Exact` -> HTTPRoute `path.type: Exact`, `Prefix` -> `PathPrefix`. `/api` 를 Prefix 로 옮기면 `/api/v2` 도 api 로 가므로 오답이다.
- Ingress `tls[]` 는 Gateway 리스너의 `protocol: HTTPS` + `tls.certificateRefs` 로 옮긴다. 인증서 Secret 은 Gateway 와 같은 네임스페이스.
- 확인: NodePort 번호는 `kubectl -n mig-tls get svc` 에서 `store-gw-nginx` 의 443 포트를 본다.
