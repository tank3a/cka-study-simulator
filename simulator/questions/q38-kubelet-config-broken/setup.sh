set -uo pipefail
source "$LIB/common.sh"
ns_create k8s kubelet-fix
kapply k8s -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: canary
  namespace: kubelet-fix
  labels: {exam.q: q38-kubelet-config-broken}
spec:
  nodeName: k8s-worker2
  # without these the default 300s NoExecute tolerations evict (delete) canary while the node is NotReady,
  # and the task ("do not re-create canary") would become unsolvable after 5 minutes
  tolerations:
  - {key: node.kubernetes.io/not-ready, operator: Exists, effect: NoExecute}
  - {key: node.kubernetes.io/unreachable, operator: Exists, effect: NoExecute}
  containers:
  - name: pause
    image: registry.k8s.io/pause:3.10
EOF
wait_ready k8s pod/canary -n kubelet-fix 60 || true
# fault 1: kubelet config points to a CA file that does not exist -> kubelet exits at start
# fault 2: kubelet runtime endpoint typo in the kubelet config (containerRuntimeEndpoint lives in config.yaml on this node image, not in kubeadm-flags.env)
node_sh k8s-node2 '
f=/var/lib/kubelet/config.yaml
[ -f "$f" ] || { echo "no $f" >&2; exit 1; }
sed -i "s#clientCAFile: /etc/kubernetes/pki/ca.crt#clientCAFile: /etc/kubernetes/pki/ca-bundle.crt#" "$f"
sed -i "s#^containerRuntimeEndpoint: unix:///run/containerd/containerd\.sock#containerRuntimeEndpoint: unix:///run/containerd/containerd.sck#" "$f"
systemctl daemon-reload
systemctl restart kubelet || true
exit 0'
