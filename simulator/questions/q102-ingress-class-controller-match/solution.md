# q102 풀이 (IngressClass 와 컨트롤러 매칭, deprecated 어노테이션)

문서: https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/

```bash
kubectl config use-context k8s
kubectl get ingressclass -o custom-columns=NAME:.metadata.name,CONTROLLER:.spec.controller
#   fix-nginx    k8s.io/ingress-nginx          <- ingress-nginx 가 처리하는 클래스
#   fix-haproxy  haproxy.org/ingress-controller
echo fix-nginx > /home/candidate/ing-class.txt

kubectl -n ing-fix patch ingress shop -p '{"spec":{"ingressClassName":"fix-nginx"}}'

kubectl -n ing-fix patch ingress legacy -p '{"spec":{"ingressClassName":"fix-nginx"}}'
kubectl -n ing-fix annotate ingress legacy kubernetes.io/ingress.class-

kubectl -n ing-fix get ingress -o custom-columns=NAME:.metadata.name,CLASS:.spec.ingressClassName
```

- 컨트롤러는 `spec.controller` 문자열이 자신과 같은 IngressClass 의 Ingress 만 처리한다. 이름이 비슷해도 `controller` 값으로 판단한다.
- `kubernetes.io/ingress.class` 어노테이션은 deprecated 이며 `spec.ingressClassName` 으로 대체된다. 둘을 동시에 두지 말 것.
- 한 번에 두 곳을 고칠 때 `kubectl edit` 보다 `patch` 가 빠르다.
