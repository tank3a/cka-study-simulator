set -uo pipefail
source "$LIB/assert.sh"
N=k8s-node2
check_node_sh "kubelet clientCAFile points to an existing file" 2 $N 'f=$(awk "/clientCAFile/{print \$2}" /var/lib/kubelet/config.yaml); [ -n "$f" ] && [ -f "$f" ]'
check_node_sh "kubelet runtime endpoint is not mistyped" 1 $N '! grep -q "containerd\.sck" /var/lib/kubelet/config.yaml /var/lib/kubelet/kubeadm-flags.env 2>/dev/null && grep -q "^containerRuntimeEndpoint: .*containerd\.sock" /var/lib/kubelet/config.yaml'
check_node_cmd "kubelet is active" 1 $N -- systemctl is-active --quiet kubelet
# the node/pod Ready conditions stay "Ready" for ~40-50 s after the kubelet died (node-monitor grace period): count them only while the kubelet runs
kubelet_up() { on_node k8s-node2 systemctl is-active --quiet kubelet; }
node_rdy() { kubelet_up && kc k8s wait --for=condition=Ready node/k8s-worker2 --timeout=5s; }
pod_rdy() { kubelet_up && kc k8s -n kubelet-fix wait --for=condition=Ready pod/canary --timeout=5s; }
check_eventually "node k8s-worker2 is Ready" 2 120 -- node_rdy
check_eventually "pod canary Ready again" 1 60 -- pod_rdy
# gated on the node being Ready again (the untouched Pod still reports restartCount 0)
check_sh "canary still bound to k8s-worker2 and its container never terminated (not re-created)" 1 'kubelet_up && kc k8s wait --for=condition=Ready node/k8s-worker2 --timeout=1s >/dev/null 2>&1 && [ "$(kc k8s -n kubelet-fix get pod canary -o jsonpath="{.spec.nodeName}")" = k8s-worker2 ] && [ "$(kc k8s -n kubelet-fix get pod canary -o jsonpath="{.status.containerStatuses[0].restartCount}")" = 0 ]'
