# q98 풀이 (Gateway allowedRoutes 네임스페이스 selector)

문서: https://gateway-api.sigs.k8s.io/guides/user-guides/http-routing/

```bash
kubectl config use-context k8s
kubectl get gatewayclass nginx -o jsonpath='{.spec.controllerName}' > /home/candidate/gwc-controller.txt

kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: shared-gw, namespace: gw-multi}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    hostname: "*.apps.example.com"
    allowedRoutes:
      namespaces:
        from: Selector
        selector:
          matchLabels: {shared-gw-access: "true"}
YAML

kubectl label ns gw-team-a shared-gw-access=true

kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: a-route, namespace: gw-team-a}
spec:
  parentRefs:
  - {name: shared-gw, namespace: gw-multi, sectionName: http}
  hostnames: ["a.apps.example.com"]
  rules:
  - backendRefs: [{name: app-a, port: 80}]
YAML

kubectl -n gw-team-a get httproute a-route -o jsonpath='{.status.parents[0].conditions}'
kubectl -n gw-team-b get httproute b-route -o jsonpath='{.status.parents[0].conditions}'   # Accepted=False, NotAllowedByListeners
```

- `allowedRoutes.namespaces.from` 값: `Same`(기본), `All`, `Selector`. Selector 는 네임스페이스 라벨로 판단하므로 `kubectl label ns` 가 필요하다.
- 다른 네임스페이스의 Gateway 를 참조할 때는 `parentRefs[].namespace` 를 반드시 적는다.
- 라벨이 없는 `gw-team-b` 는 Gateway 가 거부하며 `Accepted=False` 가 된다. 라벨은 붙이지 말 것.
