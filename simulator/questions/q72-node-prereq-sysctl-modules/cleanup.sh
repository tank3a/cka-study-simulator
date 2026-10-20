set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-node1 '
rm -f /etc/modules-load.d/k8s.conf /etc/sysctl.d/99-k8s-cri.conf /opt/cka/prereq-report.txt
sed -i "/^#*[[:space:]]*\/swapfile-cka/d" /etc/fstab
[ -f /etc/containerd/config.toml ] && sed -i "s/SystemdCgroup = false/SystemdCgroup = true/" /etc/containerd/config.toml
true
'
