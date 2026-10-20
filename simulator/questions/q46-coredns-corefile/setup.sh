set -uo pipefail
source "$LIB/common.sh"
ns_create k8s dns-fix
term_sh 'mkdir -p /home/candidate/q46 && rm -f /home/candidate/q46/nslookup.txt'
kapply k8s -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: dns-fix, labels: {exam.q: q46-coredns-corefile}}
spec:
  replicas: 1
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      containers:
      - name: httpd
        image: busybox:1.37
        command: ["sh", "-c", "mkdir -p /www; echo hello-web > /www/index.html; exec httpd -f -p 80 -h /www"]
---
apiVersion: v1
kind: Service
metadata: {name: web, namespace: dns-fix, labels: {exam.q: q46-coredns-corefile}}
spec:
  selector: {app: web}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: client, namespace: dns-fix, labels: {exam.q: q46-coredns-corefile}}
spec:
  replicas: 1
  selector: {matchLabels: {app: client}}
  template:
    metadata: {labels: {app: client}}
    spec:
      containers:
      - {name: client, image: "busybox:1.37", command: ["sh", "-c", "sleep 36000"]}
EOF
kc k8s -n dns-fix rollout status deploy/client --timeout=60s >/dev/null 2>&1 || true
cf=$(kc k8s -n kube-system get cm coredns -o jsonpath='{.data.Corefile}')
if printf '%s' "$cf" | grep -q 'kubernetes cluster\.local'; then
  tmp=$(mktemp)
  printf '%s\n' "$cf" | sed -e 's/kubernetes cluster\.local/kubernetes cluster.lcl/' -e 's#forward \. /etc/resolv.conf#forward . 10.255.255.1#' > "$tmp"
  kc k8s -n kube-system create configmap coredns --from-file=Corefile="$tmp" --dry-run=client -o yaml | kc k8s apply -f - >/dev/null
  rm -f "$tmp"
  kc k8s -n kube-system rollout restart deploy/coredns >/dev/null
  kc k8s -n kube-system rollout status deploy/coredns --timeout=90s >/dev/null 2>&1 || true
fi
