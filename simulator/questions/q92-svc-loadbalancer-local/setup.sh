set -uo pipefail
source "$LIB/common.sh"
NS=svc-lb
ns_create k8s "$NS"
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: apps/v1
kind: Deployment
metadata: {name: shop}
spec:
  replicas: 2
  selector: {matchLabels: {app: shop, tier: web}}
  template:
    metadata: {labels: {app: shop, tier: web}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
MANIFEST
wait_ready k8s deploy/shop -n "$NS" 120
exit 0
