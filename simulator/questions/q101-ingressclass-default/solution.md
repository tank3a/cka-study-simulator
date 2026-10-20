# q101 풀이 (IngressClass 생성과 default 지정)

문서: https://kubernetes.io/docs/concepts/services-networking/ingress/

```bash
kubectl config use-context k8s
kubectl get ingressclass                                   # public 이 default 인지 확인

# 1) default 가 둘이면 Ingress 생성이 거부되므로 먼저 public 의 default 를 해제
kubectl annotate ingressclass public ingressclass.kubernetes.io/is-default-class-
# 또는: kubectl annotate ingressclass public ingressclass.kubernetes.io/is-default-class=false --overwrite

# 2) internal 생성 + default
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: internal
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: k8s.io/ingress-nginx
YAML

# 3) ingressClassName 없이 Ingress 생성 -> 어드미션이 internal 을 채운다
kubectl -n ing-class create ingress docs --rule='docs.example.com/*=docs:80'
kubectl -n ing-class get ingress docs -o jsonpath='{.spec.ingressClassName}'
```

- IngressClass 는 클러스터 범위 리소스이고 `spec.controller` 가 어떤 컨트롤러가 처리할지 정한다.
- default 표시는 어노테이션 `ingressclass.kubernetes.io/is-default-class: "true"`. default 가 둘 이상이면 클래스 없는 Ingress 생성이 거부된다.
- default 는 Ingress **생성 시점**에 채워진다. 기존 Ingress 는 바뀌지 않는다.
