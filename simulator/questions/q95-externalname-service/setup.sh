set -uo pipefail
source "$LIB/common.sh"
ns_create k8s xn-lab
ns_create k8s xn-shared
kapply k8s -n xn-shared -f - <<MANIFEST
apiVersion: apps/v1
kind: Deployment
metadata: {name: backend}
spec:
  replicas: 1
  selector: {matchLabels: {app: backend}}
  template:
    metadata: {labels: {app: backend}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
---
apiVersion: v1
kind: Service
metadata: {name: backend}
spec:
  selector: {app: backend}
  ports: [{port: 80, targetPort: 80}]
MANIFEST
kapply k8s -n xn-lab -f - <<MANIFEST
apiVersion: v1
kind: Pod
metadata: {name: tester}
spec:
  containers:
  - {name: bb, image: "busybox:1.37", command: ["sleep", "86400"]}
MANIFEST
wait_ready k8s deploy/backend -n xn-shared 120
wait_ready k8s pod/tester -n xn-lab 120
exit 0
