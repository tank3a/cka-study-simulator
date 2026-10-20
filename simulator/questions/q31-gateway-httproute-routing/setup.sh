set -uo pipefail
source "$LIB/common.sh"
NS=gw-route
ns_create k8s "$NS"
if ! kc k8s get gatewayclass nginx >/dev/null 2>&1; then
  log "WARNING: GatewayClass 'nginx' not found; gateway-api addon missing?"
fi
for v in v1 v2; do
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: v1
kind: ConfigMap
metadata: {name: app-$v-conf}
data:
  default.conf: |
    server { listen 80; location / { return 200 "$v\n"; } }
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: app-$v}
spec:
  replicas: 1
  selector: {matchLabels: {app: app-$v}}
  template:
    metadata: {labels: {app: app-$v}}
    spec:
      containers:
      - name: nginx
        image: "nginx:1.27"
        ports: [{containerPort: 80}]
        volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
      volumes:
      - {name: conf, configMap: {name: app-$v-conf}}
---
apiVersion: v1
kind: Service
metadata: {name: app-$v}
spec:
  selector: {app: app-$v}
  ports: [{port: 80, targetPort: 80}]
MANIFEST
done
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: web-gw}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces: {from: Same}
MANIFEST
wait_ready k8s deploy/app-v1 -n "$NS" 120
wait_ready k8s deploy/app-v2 -n "$NS" 120
wait_for 120 -- kc k8s -n "$NS" rollout status deploy/web-gw-nginx --timeout=2s
exit 0
