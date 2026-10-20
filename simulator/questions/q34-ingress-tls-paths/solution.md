# q34 풀이 (Ingress: path + TLS) - 선택 문제, 저충실도

문서: https://kubernetes.io/docs/concepts/services-networking/ingress/
(컨트롤러 목록: https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

ingress-nginx는 2026년 3월에 retired 되었다. 이 문제는 Ingress API 필드(spec) 위주로 채점하고,
컨트롤러가 설치된 경우에만 실제 HTTP 응답을 추가로 확인한다. 실제 시험에서는 Gateway API 쪽이 더 자주 나온다.

```bash
kubectl config use-context k8s
kubectl -n ing-lab create ingress site --class=nginx \
  --rule="site.example.com/green*=green:80,tls=site-tls" \
  --rule="site.example.com/blue*=blue:80" --dry-run=client -o yaml > site.yaml
vim site.yaml      # tls 항목 확인: hosts: [site.example.com], secretName: site-tls
kubectl apply -f site.yaml
```

직접 작성하는 경우:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: site, namespace: ing-lab}
spec:
  ingressClassName: nginx
  tls:
  - hosts: [site.example.com]
    secretName: site-tls
  rules:
  - host: site.example.com
    http:
      paths:
      - {path: /green, pathType: Prefix, backend: {service: {name: green, port: {number: 80}}}}
      - {path: /blue,  pathType: Prefix, backend: {service: {name: blue,  port: {number: 80}}}}
```

- `--rule` 끝의 `*` 는 pathType Prefix 를 뜻한다 (없으면 Exact). `,tls=<secret>` 로 TLS 섹션이 만들어진다. 생성 후 hosts 가 들어갔는지 확인.
