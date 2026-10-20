set -uo pipefail
source "$LIB/common.sh"
ns_create k8s egress-dns
for t in backend intruder; do
kapply k8s -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata: {name: $t, namespace: egress-dns, labels: {exam.q: q47-netpol-egress-dns}}
spec:
  replicas: 1
  selector: {matchLabels: {app: $t}}
  template:
    metadata: {labels: {app: $t}}
    spec:
      containers:
      - name: httpd
        image: busybox:1.37
        command: ["sh", "-c", "mkdir -p /www; echo $t > /www/index.html; exec httpd -f -p 80 -h /www"]
---
apiVersion: v1
kind: Service
metadata: {name: $t, namespace: egress-dns, labels: {exam.q: q47-netpol-egress-dns}}
spec:
  selector: {app: $t}
  ports: [{port: 80, targetPort: 80}]
EOF
done
kapply k8s -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata: {name: client, namespace: egress-dns, labels: {exam.q: q47-netpol-egress-dns}}
spec:
  replicas: 1
  selector: {matchLabels: {app: client}}
  template:
    metadata: {labels: {app: client}}
    spec:
      containers:
      - {name: client, image: "busybox:1.37", command: ["sh", "-c", "sleep 36000"]}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: client-egress, namespace: egress-dns, labels: {exam.q: q47-netpol-egress-dns}}
spec:
  podSelector:
    matchLabels: {app: client}
  policyTypes: [Egress]
  egress:
  - to:
    - podSelector:
        matchLabels: {app: backend}
    ports:
    - {protocol: TCP, port: 80}
EOF
