set -uo pipefail
source "$LIB/common.sh"
ns_create k8s egress-lab
ns_create k8s egress-data
kapply k8s -n egress-lab -f - <<MANIFEST
apiVersion: v1
kind: Pod
metadata: {name: client, labels: {app: client}}
spec:
  containers:
  - {name: bb, image: "busybox:1.37", command: ["sleep", "86400"]}
MANIFEST
for b in db cache; do
kapply k8s -n egress-data -f - <<MANIFEST
apiVersion: apps/v1
kind: Deployment
metadata: {name: $b}
spec:
  replicas: 1
  selector: {matchLabels: {app: $b}}
  template:
    metadata: {labels: {app: $b}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
---
apiVersion: v1
kind: Service
metadata: {name: $b}
spec:
  selector: {app: $b}
  ports: [{port: 80, targetPort: 80}]
MANIFEST
done
wait_ready k8s pod/client -n egress-lab 120
wait_ready k8s deploy/db -n egress-data 120
wait_ready k8s deploy/cache -n egress-data 120
exit 0
