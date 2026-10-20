set -uo pipefail
source "$LIB/common.sh"
NS=gw-tls
ns_create k8s "$NS"
if ! kc k8s get gatewayclass nginx >/dev/null 2>&1; then
  log "WARNING: GatewayClass 'nginx' not found; gateway-api addon missing?"
fi
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: v1
kind: ConfigMap
metadata: {name: shop-conf}
data:
  default.conf: |
    server { listen 80; location / { return 200 "shop\n"; } }
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: shop}
spec:
  replicas: 1
  selector: {matchLabels: {app: shop}}
  template:
    metadata: {labels: {app: shop}}
    spec:
      containers:
      - name: nginx
        image: "nginx:1.27"
        ports: [{containerPort: 80}]
        volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
      volumes:
      - {name: conf, configMap: {name: shop-conf}}
---
apiVersion: v1
kind: Service
metadata: {name: shop}
spec:
  selector: {app: shop}
  ports: [{port: 80, targetPort: 80}]
MANIFEST
if ! kc k8s -n "$NS" get secret shop-tls >/dev/null 2>&1; then
  T=$(mktemp -d)
  openssl req -x509 -newkey rsa:2048 -nodes -days 365 -subj "/CN=shop.example.com" \
    -addext "subjectAltName=DNS:shop.example.com" -keyout "$T/tls.key" -out "$T/tls.crt" >/dev/null 2>&1
  kc k8s -n "$NS" create secret tls shop-tls --cert="$T/tls.crt" --key="$T/tls.key"
  rm -rf "$T"
fi
wait_ready k8s deploy/shop -n "$NS" 120
exit 0
