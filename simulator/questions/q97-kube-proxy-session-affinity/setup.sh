set -uo pipefail
source "$LIB/common.sh"
NS=kp-affinity
ns_create k8s "$NS"
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: apps/v1
kind: Deployment
metadata: {name: sticky}
spec:
  replicas: 3
  selector: {matchLabels: {app: sticky}}
  template:
    metadata: {labels: {app: sticky}}
    spec:
      containers:
      - name: nginx
        image: "nginx:1.27"
        command: ["sh", "-c", "hostname > /usr/share/nginx/html/index.html; exec nginx -g 'daemon off;'"]
        ports: [{containerPort: 80}]
---
apiVersion: v1
kind: Pod
metadata: {name: tester}
spec:
  containers:
  - {name: bb, image: "busybox:1.37", command: ["sleep", "86400"]}
MANIFEST
if ! kc k8s -n "$NS" get svc sticky >/dev/null 2>&1; then
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: v1
kind: Service
metadata: {name: sticky}
spec:
  selector: {app: sticky}
  ports: [{port: 80, targetPort: 80}]
MANIFEST
fi
if ! kc k8s -n "$NS" get cm orig >/dev/null 2>&1; then
  U=$(kc k8s -n "$NS" get svc sticky -o jsonpath='{.metadata.uid}')
  kc k8s -n "$NS" create cm orig --from-literal=uid="$U" >/dev/null
fi
wait_ready k8s deploy/sticky -n "$NS" 120
wait_ready k8s pod/tester -n "$NS" 120
exit 0
