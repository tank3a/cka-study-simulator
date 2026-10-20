set -uo pipefail
source "$LIB/common.sh"
NS=ing-def
ns_create k8s "$NS"
if ! kc k8s get ingressclass nginx >/dev/null 2>&1; then
  log "NOTE: IngressClass 'nginx' not installed; this question is spec-only (low fidelity)."
fi
for v in web api fallback; do
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: v1
kind: ConfigMap
metadata: {name: $v-conf}
data:
  default.conf: |
    server { listen 80; location / { return 200 "$v\n"; } }
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: $v}
spec:
  replicas: 1
  selector: {matchLabels: {app: $v}}
  template:
    metadata: {labels: {app: $v}}
    spec:
      containers:
      - name: nginx
        image: "nginx:1.27"
        ports: [{containerPort: 80}]
        volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
      volumes:
      - {name: conf, configMap: {name: $v-conf}}
---
apiVersion: v1
kind: Service
metadata: {name: $v}
spec:
  selector: {app: $v}
  ports: [{port: 80, targetPort: 80}]
MANIFEST
done
for v in web api fallback; do wait_ready k8s deploy/$v -n "$NS" 120; done
exit 0
