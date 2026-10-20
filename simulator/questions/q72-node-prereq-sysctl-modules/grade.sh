set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-node1
check_node_sh "modules-load file lists overlay and br_netfilter" 2 $N 'grep -qx overlay /etc/modules-load.d/k8s.conf && grep -qx br_netfilter /etc/modules-load.d/k8s.conf'
check_node_sh "sysctl file sets the three keys to 1" 2 $N 'F=/etc/sysctl.d/99-k8s-cri.conf; grep -Eq "^net.bridge.bridge-nf-call-iptables *= *1" $F && grep -Eq "^net.bridge.bridge-nf-call-ip6tables *= *1" $F && grep -Eq "^net.ipv4.ip_forward *= *1" $F'
check_node_sh "fstab has no active swap entry" 1 $N '! grep -Ev "^[[:space:]]*#" /etc/fstab | grep -qw swap'
# lab node: the node containers share the Docker VM kernel, so `swapoff -a` fails there (EPERM) and the VM swap stays active.
# Accept: no swap at all, or only the VM-level /var/lib/swap remains. Counts only once the fstab entry is gone (untouched must not score).
check_node_sh "swap is off now" 1 $N '! grep -Ev "^[[:space:]]*#" /etc/fstab | grep -qw swap && [ "$(swapon --show=NAME --noheadings | grep -vx "/var/lib/swap" | wc -l)" = 0 ]'
check_node_sh "containerd config uses SystemdCgroup = true" 1 $N 'grep -Eq "SystemdCgroup *= *true" /etc/containerd/config.toml'
check_file "report file" 1 $N /opt/cka/prereq-report.txt 'net.ipv4.ip_forward = 1'
