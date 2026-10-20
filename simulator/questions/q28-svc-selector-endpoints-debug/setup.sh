set -uo pipefail
source "$LIB/common.sh"
NS=svc-debug
ns_create k8s "$NS"
term_sh 'rm -f /home/candidate/api-endpoints.txt'
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: apps/v1
kind: Deployment
metadata: {name: api}
spec:
  replicas: 2
  selector: {matchLabels: {app: api, tier: backend}}
  template:
    metadata: {labels: {app: api, tier: backend}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
---
apiVersion: v1
kind: Pod
metadata: {name: client}
spec:
  containers:
  - {name: bb, image: "busybox:1.37", command: ["sleep", "86400"]}
MANIFEST
# Only seed the broken Service if it does not exist yet (idempotent; do not undo the candidate's fix).
if ! kc k8s -n "$NS" get svc api >/dev/null 2>&1; then
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: v1
kind: Service
metadata: {name: api}
spec:
  selector: {app: api-server}
  ports:
  - {port: 80, targetPort: 8080}
MANIFEST
fi
wait_ready k8s deploy/api -n "$NS" 120
wait_ready k8s pod/client -n "$NS" 120
exit 0
