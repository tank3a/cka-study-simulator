# q33 풀이 (Ingress -> HTTPRoute 마이그레이션)

문서: https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/
(Ingress 대응표: https://kubernetes.io/docs/concepts/services-networking/gateway/ , Ingress 필드: https://kubernetes.io/docs/concepts/services-networking/ingress/)

```bash
kubectl config use-context k8s
kubectl -n legacy-ing get ingress legacy -o yaml     # host, path, pathType, backend 확인
```

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: legacy-route
  namespace: legacy-ing
spec:
  parentRefs:
  - name: main-gw
  hostnames:
  - blog.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /}
    backendRefs:
    - {name: blog, port: 80}
  - matches:
    - path: {type: PathPrefix, value: /docs}
    backendRefs:
    - {name: docs, port: 80}
```

```bash
kubectl apply -f legacy-route.yaml
kubectl -n legacy-ing describe httproute legacy-route      # Accepted=True 확인
kubectl -n legacy-ing delete ingress legacy                # 새 라우트 확인 후 삭제
```

- 변환 규칙: Ingress `pathType: Prefix` = HTTPRoute `PathPrefix`, `backend.service.port.number` = `backendRefs[].port`, `spec.rules[].host` = `hostnames`.
- 순서: 새 라우트가 동작하는 것을 확인한 다음 Ingress 삭제.
