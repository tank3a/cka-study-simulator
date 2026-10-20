set -uo pipefail
source "$LIB/common.sh"
NS=svc-nodeport
ns_create k8s "$NS"
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: apps/v1
kind: Deployment
metadata: {name: web}
spec:
  replicas: 3
  selector: {matchLabels: {app: web, tier: frontend}}
  template:
    metadata: {labels: {app: web, tier: frontend}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
---
apiVersion: v1
kind: Pod
metadata: {name: tester}
spec:
  containers:
  - {name: bb, image: "busybox:1.37", command: ["sleep", "86400"]}
MANIFEST
wait_ready k8s deploy/web -n "$NS" 120
wait_ready k8s pod/tester -n "$NS" 120
exit 0
