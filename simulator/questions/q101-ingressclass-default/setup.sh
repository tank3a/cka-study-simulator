set -uo pipefail
source "$LIB/common.sh"
NS=ing-class
ns_create k8s "$NS"
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: v1
kind: Service
metadata: {name: docs}
spec:
  selector: {app: docs}
  ports: [{port: 80, targetPort: 80}]
MANIFEST
# Seed the original class only once (the candidate removes its default annotation).
if ! kc k8s get ingressclass public >/dev/null 2>&1; then
kapply k8s -f - <<MANIFEST
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: public
  labels: {exam.q: "$QID"}
  annotations: {ingressclass.kubernetes.io/is-default-class: "true"}
spec:
  controller: k8s.io/ingress-nginx
MANIFEST
fi
exit 0
