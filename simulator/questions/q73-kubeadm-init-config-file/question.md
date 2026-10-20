Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

A new cluster `prod-eu` will be bootstrapped with `kubeadm init --config`. Write the configuration file `/opt/cka/init-config.yaml` (one multi-document YAML) with:

- `ClusterConfiguration`: Kubernetes version `v1.34.0`, cluster name `prod-eu`, control plane endpoint `cp.prod.example.com:6443`, Pod subnet `10.200.0.0/16`, Service subnet `10.96.0.0/16`, extra API server certificate SANs `cp.prod.example.com` and `10.0.0.10`.
- `InitConfiguration`: node name `prod-cp1`, CRI socket `unix:///run/containerd/containerd.sock`, API server advertise address `10.0.0.10`, bind port `6443`.
- `KubeletConfiguration`: `cgroupDriver: systemd`.

Then:
1. Validate the file with kubeadm; it must pass.
2. Save the list of control plane images that kubeadm would pull for this configuration to `/opt/cka/init-images.txt`.

Constraints:
- Do **not** run `kubeadm init` or `kubeadm reset` on this node.
- Start from `kubeadm config print init-defaults` if you like; remove what you do not need.
