set -uo pipefail
source "$LIB/common.sh"
ns_create k8s gw-multi
ns_create k8s gw-team-a
ns_create k8s gw-team-b
if ! kc k8s get gatewayclass nginx >/dev/null 2>&1; then
  log "WARNING: GatewayClass 'nginx' not found; gateway-api addon missing?"
fi
NS=gw-team-a
for v in app-a; do
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
NS=gw-team-b
for v in app-b; do
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
kapply k8s -n gw-team-b -f - <<MANIFEST
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: b-route}
spec:
  parentRefs:
  - {name: shared-gw, namespace: gw-multi, sectionName: http}
  hostnames: ["b.apps.example.com"]
  rules:
  - backendRefs: [{name: app-b, port: 80}]
MANIFEST
wait_ready k8s deploy/app-a -n gw-team-a 120
wait_ready k8s deploy/app-b -n gw-team-b 120
exit 0
