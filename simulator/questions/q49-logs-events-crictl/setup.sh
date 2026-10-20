set -uo pipefail
source "$LIB/common.sh"
ns_create k8s logs-lab
term_sh 'rm -rf /home/candidate/q49'
on_node k8s-node1 rm -f /opt/cka/q49-shipper-id.txt
kapply k8s -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata: {name: multi, namespace: logs-lab, labels: {exam.q: q49-logs-events-crictl}}
spec:
  nodeName: k8s-worker
  containers:
  - name: collector
    image: busybox:1.37
    command: ["sh", "-c", "while true; do echo collector heartbeat; sleep 5; done"]
  - name: shipper
    image: busybox:1.37
    command: ["sh", "-c", "i=0; while true; do i=$((i+1)); echo shipping batch $i; echo shipper WARN retry $i >&2; sleep 5; done"]
---
apiVersion: v1
kind: Pod
metadata: {name: crasher, namespace: logs-lab, labels: {exam.q: q49-logs-events-crictl}}
spec:
  containers:
  - name: app
    image: busybox:1.37
    command: ["sh", "-c", "echo starting; echo 'fatal: license key missing' >&2; exit 3"]
EOF
