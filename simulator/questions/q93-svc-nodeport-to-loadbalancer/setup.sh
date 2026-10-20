set -uo pipefail
source "$LIB/common.sh"
NS=svc-lb2
ns_create k8s "$NS"
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: apps/v1
kind: Deployment
metadata: {name: api}
spec:
  replicas: 2
  selector: {matchLabels: {app: api}}
  template:
    metadata: {labels: {app: api}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
MANIFEST
# Create the Service only once, so a re-seed never undoes the candidate's edit.
if ! kc k8s -n "$NS" get svc api >/dev/null 2>&1; then
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: v1
kind: Service
metadata: {name: api}
spec:
  type: NodePort
  selector: {app: api}
  ports: [{port: 8080, targetPort: 80, nodePort: 30091}]
MANIFEST
fi
# Remember the original UID so the grader can detect delete/recreate.
if ! kc k8s -n "$NS" get cm orig >/dev/null 2>&1; then
  UID_=$(kc k8s -n "$NS" get svc api -o jsonpath='{.metadata.uid}')
  kc k8s -n "$NS" create cm orig --from-literal=uid="$UID_" >/dev/null
fi
wait_ready k8s deploy/api -n "$NS" 120
exit 0
