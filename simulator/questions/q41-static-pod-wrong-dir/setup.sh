set -uo pipefail
source "$LIB/common.sh"
ns_create k8s static-demo
on_node k8s-node1 rm -f /etc/kubernetes/manifests/audit-agent.yaml
# manifest in a wrong (singular) directory, with a non-existing image tag
node_put k8s-node1 /etc/kubernetes/manifest/audit-agent.yaml 0644 <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: audit-agent
  namespace: static-demo
  labels:
    exam.q: q41-static-pod-wrong-dir
spec:
  containers:
  - name: agent
    image: busybox:1.37.99
    command: ["sh", "-c", "while true; do echo audit-ok; sleep 10; done"]
EOF
