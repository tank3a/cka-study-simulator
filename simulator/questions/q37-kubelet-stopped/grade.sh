set -uo pipefail
source "$LIB/assert.sh"
check_file "notready node name saved" 1 term /home/candidate/q37/notready-node.txt '^ek8s-worker[[:space:]]*$'
check_node_cmd "kubelet is active on ek8s-worker" 1 ek8s-node1 -- systemctl is-active --quiet kubelet
check_node_cmd "kubelet is enabled (survives reboot)" 2 ek8s-node1 -- systemctl is-enabled --quiet kubelet
check_eventually "node ek8s-worker is Ready" 2 90 -- kc ek8s wait --for=condition=Ready node/ek8s-worker --timeout=5s
check_sh "all ek8s nodes Ready, node objects intact" 1 'n=$(kc ek8s get nodes --no-headers | wc -l); [ "$n" -eq 2 ] && kc ek8s get nodes --no-headers | awk "\$2!=\"Ready\"{f=1} END{exit f}"'
