# q31 풀이 (HTTPRoute: path + header 매칭)

문서: https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/
(참고: https://gateway-api.sigs.k8s.io/api-types/httproute/ 는 404 이므로 열지 말 것. 시험에서도 위 user-guides 페이지를 쓴다.)

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-route
  namespace: gw-route
spec:
  parentRefs:
  - name: web-gw
  hostnames:
  - app.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /v1}
    backendRefs:
    - {name: app-v1, port: 80}
  - matches:
    - path: {type: PathPrefix, value: /v2}
    backendRefs:
    - {name: app-v2, port: 80}
  - matches:
    - path: {type: PathPrefix, value: /}
      headers:
      - {type: Exact, name: X-Env, value: canary}
    backendRefs:
    - {name: app-v2, port: 80}
  - matches:
    - path: {type: PathPrefix, value: /}
    backendRefs:
    - {name: app-v1, port: 80}
```

- 매칭 우선순위: 더 구체적인 match(헤더까지 있는 `/`)가 헤더 없는 `/` 보다 우선한다. 규칙 순서보다 specificity가 먼저다.
- 검증: `kubectl -n gw-route describe httproute app-route` 에서 Accepted/ResolvedRefs 가 True 인지 본다.
- 외부 테스트: `curl -H 'Host: app.example.com' http://<node-ip>:<nodePort>/v1`
  (`kubectl -n gw-route get svc` 에서 Gateway용 Service의 NodePort 확인).
