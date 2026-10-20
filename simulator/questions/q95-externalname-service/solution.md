# q95 풀이 (ExternalName Service)

문서: https://kubernetes.io/docs/concepts/services-networking/service/

```bash
kubectl config use-context k8s
kubectl -n xn-lab apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata: {name: legacy-db}
spec:
  type: ExternalName
  externalName: backend.xn-shared.svc.cluster.local
---
apiVersion: v1
kind: Service
metadata: {name: cdn}
spec:
  type: ExternalName
  externalName: assets.example.org
YAML
# 주의: `kubectl create service externalname` 은 selector(app=<name>)를 자동으로 넣는다. 쓰려면 `kubectl -n xn-lab patch svc legacy-db --type=json -p '[{"op":"remove","path":"/spec/selector"}]'` 로 제거한다.

kubectl -n xn-lab get svc
kubectl -n xn-lab exec tester -- nslookup legacy-db          # CNAME -> backend.xn-shared.svc.cluster.local
kubectl -n xn-lab exec tester -- wget -qO- http://legacy-db  # nginx 기본 페이지
```

- ExternalName 은 프록시/ClusterIP 없이 DNS CNAME 만 돌려준다. selector 와 endpoints 가 없다.
- 다른 네임스페이스의 Service 는 `<svc>.<ns>.svc.cluster.local` 로 지정한다. 짧은 이름 `backend` 만 쓰면 `xn-lab` 안에서 해석되어 실패한다.
- 함정: ExternalName 은 HTTP 호스트 헤더/TLS SNI 를 바꾸지 않는다. 이 실습의 nginx 는 모든 Host 를 받으므로 통과한다.
