set -uo pipefail
source "$LIB/common.sh"
NS=ing-fix
ns_create k8s "$NS"
kapply k8s -f - <<MANIFEST
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata: {name: fix-nginx, labels: {exam.q: "$QID"}}
spec: {controller: k8s.io/ingress-nginx}
---
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata: {name: fix-haproxy, labels: {exam.q: "$QID"}}
spec: {controller: haproxy.org/ingress-controller}
MANIFEST
# Seed the broken Ingresses once; never overwrite the candidate's fix.
for v in shop legacy; do
if ! kc k8s -n "$NS" get ingress $v >/dev/null 2>&1; then
  if [ "$v" = shop ]; then CLS='  ingressClassName: fix-haproxy'; ANN=''; else CLS=''; ANN='  annotations: {kubernetes.io/ingress.class: fix-nginx}'; fi
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: v1
kind: Service
metadata: {name: $v}
spec:
  selector: {app: $v}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $v
$ANN
spec:
$CLS
  rules:
  - host: $v.example.com
    http:
      paths:
      - {path: /, pathType: Prefix, backend: {service: {name: $v, port: {number: 80}}}}
MANIFEST
fi
done
exit 0
