set -uo pipefail
source "$LIB/common.sh"
ns_create k8s outage
kapply k8s -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: outage, labels: {exam.q: q42-pods-imagepull-crashloop}}
spec:
  replicas: 2
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      containers:
      - {name: web, image: "nginx:1.99-alpine"}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: api, namespace: outage, labels: {exam.q: q42-pods-imagepull-crashloop}}
spec:
  replicas: 1
  selector: {matchLabels: {app: api}}
  template:
    metadata: {labels: {app: api}}
    spec:
      containers:
      - name: api
        image: busybox:1.37
        command:
        - sh
        - -c
        - 'if [ -z "$DB_HOST" ]; then echo "FATAL: environment variable DB_HOST is not set" >&2; exit 1; fi; echo "connected to $DB_HOST"; sleep 3600'
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: cache, namespace: outage, labels: {exam.q: q42-pods-imagepull-crashloop}}
spec:
  replicas: 1
  selector: {matchLabels: {app: cache}}
  template:
    metadata: {labels: {app: cache}}
    spec:
      containers:
      - name: cache
        image: nginx:1.27
        livenessProbe:
          httpGet: {path: /, port: 8080}
          initialDelaySeconds: 2
          periodSeconds: 3
          failureThreshold: 1
EOF
