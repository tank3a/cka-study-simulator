set -uo pipefail
source "$LIB/common.sh"
NS=ing-lab
ns_create k8s "$NS"
if ! kc k8s get ingressclass nginx >/dev/null 2>&1; then
  log "NOTE: IngressClass 'nginx' not installed; this question is spec-only (low fidelity)."
fi
for v in green blue; do
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
if ! kc k8s -n "$NS" get secret site-tls >/dev/null 2>&1; then
  T=$(mktemp -d)
  openssl req -x509 -newkey rsa:2048 -nodes -days 365 -subj "/CN=site.example.com" \
    -addext "subjectAltName=DNS:site.example.com" -keyout "$T/tls.key" -out "$T/tls.crt" >/dev/null 2>&1
  kc k8s -n "$NS" create secret tls site-tls --cert="$T/tls.crt" --key="$T/tls.key"
  rm -rf "$T"
fi
wait_ready k8s deploy/green -n "$NS" 120
wait_ready k8s deploy/blue -n "$NS" 120
exit 0
