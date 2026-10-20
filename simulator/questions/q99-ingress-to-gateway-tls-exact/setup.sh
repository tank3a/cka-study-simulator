set -uo pipefail
source "$LIB/common.sh"
NS=mig-tls
ns_create k8s "$NS"
if ! kc k8s get gatewayclass nginx >/dev/null 2>&1; then
  log "WARNING: GatewayClass 'nginx' not found; gateway-api addon missing?"
fi
for v in web api; do
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
if ! kc k8s -n "$NS" get secret store-tls >/dev/null 2>&1; then
  T=$(mktemp -d)
  openssl req -x509 -newkey rsa:2048 -nodes -days 365 -subj "/CN=store.example.com" \
    -addext "subjectAltName=DNS:store.example.com" -keyout "$T/tls.key" -out "$T/tls.crt" >/dev/null 2>&1
  kc k8s -n "$NS" create secret tls store-tls --cert="$T/tls.crt" --key="$T/tls.key"
  rm -rf "$T"
fi
# Seed the Ingress only while the migration has not started (do not resurrect it after the candidate deleted it).
if ! kc k8s -n "$NS" get httproute store-route >/dev/null 2>&1 && ! kc k8s -n "$NS" get gateway store-gw >/dev/null 2>&1; then
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: store}
spec:
  ingressClassName: nginx
  tls:
  - hosts: [store.example.com]
    secretName: store-tls
  rules:
  - host: store.example.com
    http:
      paths:
      - {path: /api, pathType: Exact, backend: {service: {name: api, port: {number: 80}}}}
      - {path: /, pathType: Prefix, backend: {service: {name: web, port: {number: 80}}}}
MANIFEST
fi
wait_ready k8s deploy/web -n "$NS" 120
wait_ready k8s deploy/api -n "$NS" 120
exit 0
