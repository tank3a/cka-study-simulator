set -uo pipefail
source "$LIB/assert.sh"
check_node_sh "audit-agent.yaml is in the kubelet staticPodPath" 2 k8s-node1 'p=$(awk "/staticPodPath/{print \$2}" /var/lib/kubelet/config.yaml); [ -n "$p" ] && [ -f "$p/audit-agent.yaml" ]'
check_node_sh "image tag fixed (no 1.37.99)" 1 k8s-node1 '[ -f /etc/kubernetes/manifests/audit-agent.yaml ] && ! grep -rq "busybox:1.37.99" /etc/kubernetes/manifests/'
check_eventually "mirror pod audit-agent-k8s-worker is Ready" 2 90 -- kc k8s -n static-demo wait --for=condition=Ready pod/audit-agent-k8s-worker --timeout=5s
check_jsonpath "pod is owned by the Node (static pod)" 1 k8s pod/audit-agent-k8s-worker -n static-demo '{.metadata.ownerReferences[0].kind}' Node
check_sh "no Deployment/DaemonSet/StatefulSet used" 1 'on_node k8s-node1 test -f /etc/kubernetes/manifests/audit-agent.yaml && [ -z "$(kc k8s -n static-demo get deploy,ds,sts,rs -o name 2>/dev/null)" ]'
