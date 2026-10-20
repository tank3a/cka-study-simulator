set -uo pipefail
source "$LIB/common.sh"
NS=net-debug
ns_create k8s "$NS"
term_sh 'rm -f /home/candidate/podcidr-node1.txt /home/candidate/cni-conf.txt /home/candidate/dns-ip.txt'
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: apps/v1
kind: Deployment
metadata: {name: backend}
spec:
  replicas: 1
  selector: {matchLabels: {app: backend}}
  template:
    metadata: {labels: {app: backend}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
---
apiVersion: v1
kind: Service
metadata: {name: backend}
spec:
  selector: {app: backend}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: v1
kind: Pod
metadata: {name: healthy-client}
spec:
  containers:
  - {name: bb, image: "busybox:1.37", command: ["sleep", "86400"]}
MANIFEST
# Seed the broken Pod only if it does not exist (do not recreate it over the candidate's fix).
if ! kc k8s -n "$NS" get pod broken-client >/dev/null 2>&1; then
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: v1
kind: Pod
metadata: {name: broken-client}
spec:
  dnsPolicy: None
  dnsConfig:
    nameservers: ["192.0.2.53"]
    searches: ["net-debug.svc.cluster.local", "svc.cluster.local", "cluster.local"]
    options: [{name: ndots, value: "5"}, {name: timeout, value: "1"}]
  containers:
  - {name: bb, image: "busybox:1.37", command: ["sleep", "86400"]}
MANIFEST
fi
wait_ready k8s deploy/backend -n "$NS" 120
wait_ready k8s pod/healthy-client -n "$NS" 120
wait_ready k8s pod/broken-client -n "$NS" 120
exit 0
