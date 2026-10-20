set -uo pipefail
source "$LIB/common.sh"
# kubelet stopped AND disabled on the worker (no kubectl needed, safe to run while other ek8s tasks seed)
on_node ek8s-node1 systemctl disable --now kubelet || true
term_sh 'mkdir -p /home/candidate/q37 && rm -f /home/candidate/q37/notready-node.txt'
