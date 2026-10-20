Host: `{{host}}` (use `sudo -i` on the node)

This node is being prepared to join a cluster with kubeadm. Complete the usual prerequisites **persistently** (they must survive a reboot):

1. Kernel modules `overlay` and `br_netfilter` must be loaded at boot: file `/etc/modules-load.d/k8s.conf`.
2. File `/etc/sysctl.d/99-k8s-cri.conf` must set `net.bridge.bridge-nf-call-iptables`, `net.bridge.bridge-nf-call-ip6tables` and `net.ipv4.ip_forward` to `1`. Apply the settings with `sysctl --system` (errors for keys that this lab kernel does not expose can be ignored).
3. Swap must be off permanently: the swap entry in `/etc/fstab` must no longer be active, and swap must be disabled now (on this lab node the kernel is shared with the Docker VM, so `swapoff -a` may report an error for the VM-level swap; that error can be ignored).
4. containerd must use the systemd cgroup driver: `SystemdCgroup = true` in `/etc/containerd/config.toml`. Do **not** restart containerd on this lab node.
5. Write the output of `sysctl net.ipv4.ip_forward` to `/opt/cka/prereq-report.txt`.

Constraints:
- Do not change any other setting in `/etc/containerd/config.toml`.
