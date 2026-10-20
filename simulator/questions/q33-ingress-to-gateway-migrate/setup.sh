set -uo pipefail
source "$LIB/common.sh"
NS=legacy-ing
ns_create k8s "$NS"
if ! kc k8s get gatewayclass nginx >/dev/null 2>&1; then
  log "WARNING: GatewayClass 'nginx' not found; gateway-api addon missing?"
fi
for v in blog docs; do
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
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: main-gw}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces: {from: Same}
MANIFEST
# The Ingress is only an API object here (no Ingress controller needed). Seed it only if the migration has not been done:
# if the HTTPRoute already exists the candidate has started, so do not resurrect the Ingress.
if ! kc k8s -n "$NS" get httproute legacy-route >/dev/null 2>&1; then
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: legacy}
spec:
  ingressClassName: nginx
  rules:
  - host: blog.example.com
    http:
      paths:
      - {path: /, pathType: Prefix, backend: {service: {name: blog, port: {number: 80}}}}
      - {path: /docs, pathType: Prefix, backend: {service: {name: docs, port: {number: 80}}}}
MANIFEST
fi
wait_ready k8s deploy/blog -n "$NS" 120
wait_ready k8s deploy/docs -n "$NS" 120
wait_for 120 -- kc k8s -n "$NS" rollout status deploy/main-gw-nginx --timeout=2s
exit 0
