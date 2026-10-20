set -uo pipefail
source "$LIB/common.sh"
ns_create k8s svc-ready
kapply k8s -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata: {name: portal, namespace: svc-ready, labels: {exam.q: q48-service-readiness-nodeport}}
spec:
  replicas: 2
  selector: {matchLabels: {app: portal}}
  template:
    metadata: {labels: {app: portal}}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - {name: web, containerPort: 80}
        readinessProbe:
          httpGet: {path: /healthz, port: 80}
          initialDelaySeconds: 1
          periodSeconds: 3
---
apiVersion: v1
kind: Service
metadata: {name: portal, namespace: svc-ready, labels: {exam.q: q48-service-readiness-nodeport}}
spec:
  type: NodePort
  selector: {app: portal}
  ports:
  - {port: 80, targetPort: http, nodePort: 30048}
EOF
