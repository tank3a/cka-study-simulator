set -uo pipefail
source "$LIB/common.sh"
NS=dns-lab
ns_create k8s "$NS"
# Back up the original Corefile once (never overwrite a backup with an already edited Corefile).
if ! kc k8s -n "$NS" get cm corefile-backup >/dev/null 2>&1; then
  T=$(mktemp -d)
  kc k8s -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' > "$T/Corefile"
  if grep -q 'corp.internal' "$T/Corefile"; then
    log "ERROR: kube-system/coredns already modified and no backup found; run cleanup/reset the cluster first"
    rm -rf "$T"
    exit 1
  fi
  kc k8s -n "$NS" create cm corefile-backup --from-file=Corefile="$T/Corefile"
  rm -rf "$T"
fi
IMG=$(kc k8s -n kube-system get deploy coredns -o jsonpath='{.spec.template.spec.containers[0].image}')
kapply k8s -n "$NS" -f - <<MANIFEST
apiVersion: v1
kind: ConfigMap
metadata: {name: corp-dns-conf}
data:
  Corefile: |
    corp.internal:53 {
        hosts {
            10.1.2.3 app.corp.internal
            fallthrough
        }
        log
        errors
    }
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: corp-dns}
spec:
  replicas: 1
  selector: {matchLabels: {app: corp-dns}}
  template:
    metadata: {labels: {app: corp-dns}}
    spec:
      containers:
      - name: coredns
        image: "$IMG"
        args: ["-conf", "/etc/coredns/Corefile"]
        ports:
        - {containerPort: 53, protocol: UDP}
        - {containerPort: 53, protocol: TCP}
        volumeMounts: [{name: conf, mountPath: /etc/coredns}]
      volumes:
      - {name: conf, configMap: {name: corp-dns-conf}}
---
apiVersion: v1
kind: Service
metadata: {name: corp-dns}
spec:
  selector: {app: corp-dns}
  ports:
  - {name: dns-udp, port: 53, targetPort: 53, protocol: UDP}
  - {name: dns-tcp, port: 53, targetPort: 53, protocol: TCP}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: db}
spec:
  replicas: 1
  selector: {matchLabels: {app: db}}
  template:
    metadata: {labels: {app: db}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
---
apiVersion: v1
kind: Service
metadata: {name: db}
spec:
  selector: {app: db}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: v1
kind: Pod
metadata: {name: dnsclient}
spec:
  containers:
  - {name: bb, image: "busybox:1.37", command: ["sleep", "86400"]}
MANIFEST
wait_ready k8s deploy/corp-dns -n "$NS" 120
wait_ready k8s deploy/db -n "$NS" 120
wait_ready k8s pod/dnsclient -n "$NS" 120
exit 0
