set -uo pipefail
source "$LIB/common.sh"
ns_create k8s shop-np
ns_create k8s np-other
for t in web api db; do
kapply k8s -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata: {name: $t, namespace: shop-np, labels: {exam.q: q45-netpol-ingress-chain}}
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
EOF
done
kapply k8s -f - <<'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: deny-all-ingress, namespace: shop-np, labels: {exam.q: q45-netpol-ingress-chain}}
spec:
  podSelector: {}
  policyTypes: [Ingress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-web-to-api, namespace: shop-np, labels: {exam.q: q45-netpol-ingress-chain}}
spec:
  podSelector:
    matchLabels: {app: api}
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels: {app: webb}
    ports:
    - {protocol: TCP, port: 80}
---
apiVersion: v1
kind: Pod
metadata: {name: probe, namespace: np-other, labels: {exam.q: q45-netpol-ingress-chain}}
spec:
  containers:
  - {name: probe, image: "busybox:1.37", command: ["sh", "-c", "sleep 36000"]}
EOF
