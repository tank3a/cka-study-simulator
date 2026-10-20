set -uo pipefail
source "$LIB/common.sh"
NS=hl-dns
ns_create k8s "$NS"
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: db}
spec:
  replicas: 3
  serviceName: db-hl
  podManagementPolicy: Parallel
  selector: {matchLabels: {app: db}}
  template:
    metadata: {labels: {app: db}}
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
wait_for 120 -- bash -c "[ \"\$(kubectl --kubeconfig \"$ADMIN_KUBECONFIG\" --context k8s -n $NS get pods -l app=db -o jsonpath='{.items[*].status.phase}' | wc -w)\" -eq 3 ]"
wait_ready k8s pod/tester -n "$NS" 120
exit 0
