set -uo pipefail
source "$LIB/common.sh"
NS=kp-lab
ns_create k8s "$NS"
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: apps/v1
kind: Deployment
metadata: {name: echo}
spec:
  replicas: 2
  selector: {matchLabels: {app: echo}}
  template:
    metadata: {labels: {app: echo}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
---
apiVersion: v1
kind: Service
metadata: {name: echo}
spec:
  selector: {app: echo}
  ports: [{name: http, port: 80, targetPort: 80}]
MANIFEST
wait_ready k8s deploy/echo -n "$NS" 120
exit 0
