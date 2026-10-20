set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-node1 '
mkdir -p /opt/cka
rm -f /etc/modules-load.d/k8s.conf /etc/sysctl.d/99-k8s-cri.conf /opt/cka/prereq-report.txt
touch /etc/fstab
grep -q "^/swapfile-cka" /etc/fstab || echo "/swapfile-cka none swap sw 0 0" >> /etc/fstab
[ -f /etc/containerd/config.toml ] && sed -i "s/SystemdCgroup = true/SystemdCgroup = false/" /etc/containerd/config.toml
true
'
