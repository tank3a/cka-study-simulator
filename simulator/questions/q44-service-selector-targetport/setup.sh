set -uo pipefail
source "$LIB/common.sh"
ns_create k8s svc-lab
kapply k8s -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata: {name: shop-api, namespace: svc-lab, labels: {exam.q: q44-service-selector-targetport}}
spec:
  replicas: 2
  selector: {matchLabels: {app: shop-api}}
  template:
    metadata: {labels: {app: shop-api}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
---
apiVersion: v1
kind: Service
metadata: {name: shop-api, namespace: svc-lab, labels: {exam.q: q44-service-selector-targetport}}
spec:
  selector: {app: shop-apy}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: shop-web, namespace: svc-lab, labels: {exam.q: q44-service-selector-targetport}}
spec:
  replicas: 2
  selector: {matchLabels: {app: shop-web}}
  template:
    metadata: {labels: {app: shop-web}}
    spec:
      containers:
      - name: httpd
        image: busybox:1.37
        command: ["sh", "-c", "mkdir -p /www; echo shop-web > /www/index.html; exec httpd -f -p 8080 -h /www"]
        ports: [{containerPort: 8080}]
---
apiVersion: v1
kind: Service
metadata: {name: shop-web, namespace: svc-lab, labels: {exam.q: q44-service-selector-targetport}}
spec:
  selector: {app: shop-web}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: tester, namespace: svc-lab, labels: {exam.q: q44-service-selector-targetport}}
spec:
  replicas: 1
  selector: {matchLabels: {app: tester}}
  template:
    metadata: {labels: {app: tester}}
    spec:
      containers:
      - {name: tester, image: "busybox:1.37", command: ["sh", "-c", "sleep 36000"]}
EOF
