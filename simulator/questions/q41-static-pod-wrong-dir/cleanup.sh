set -uo pipefail
source "$LIB/common.sh"
on_node k8s-node1 rm -rf /etc/kubernetes/manifest /etc/kubernetes/manifests/audit-agent.yaml
kc k8s delete ns static-demo --ignore-not-found --wait=false
