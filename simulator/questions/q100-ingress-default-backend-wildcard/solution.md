# q100 풀이 (Ingress: defaultBackend, wildcard host, Exact/Prefix)

문서: https://kubernetes.io/docs/concepts/services-networking/ingress/

```bash
kubectl config use-context k8s
kubectl -n ing-def apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: portal}
spec:
  ingressClassName: nginx
  defaultBackend:
    service: {name: fallback, port: {number: 80}}
  rules:
  - host: "*.portal.example.com"
    http:
      paths:
      - {path: /api, pathType: Exact, backend: {service: {name: api, port: {number: 80}}}}
      - {path: /, pathType: Prefix, backend: {service: {name: web, port: {number: 80}}}}
YAML
```

명령형 뼈대: `kubectl -n ing-def create ingress portal --class=nginx --default-backend=fallback:80 --rule='*.portal.example.com/api=api:80' --rule='*.portal.example.com/*=web:80' --dry-run=client -o yaml`
(`--rule` 에서 `/path=svc:port` 는 Exact, `/path*=svc:port` 는 Prefix 가 된다. 생성된 YAML 의 pathType 을 반드시 확인한다.)

- 와일드카드 host `*.portal.example.com` 은 한 레이블만 대체한다 (`eu.portal.example.com` 은 매치, `portal.example.com` 은 불일치).
- `defaultBackend` 는 어떤 규칙에도 맞지 않는 요청을 받는다.
- 이 문제는 ingress-nginx 컨트롤러 없이도 spec 확인이 가능하다 (live 확인은 애드온이 있을 때만).
