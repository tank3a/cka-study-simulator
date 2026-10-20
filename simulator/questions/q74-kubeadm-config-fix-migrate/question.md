Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

A colleague prepared `/opt/cka/broken-init.yaml` for bootstrapping a cluster, but a review found problems. Create the corrected file `/opt/cka/fixed-init.yaml` (do not edit the original) so that:

1. It uses the newest kubeadm configuration API version `kubeadm.k8s.io/v1beta4` (convert it with kubeadm, do not retype it).
2. The CRI socket has a URL scheme (`unix://...`).
3. The Pod subnet no longer overlaps the Service subnet: use `10.244.0.0/16` for Pods and keep the Service subnet.
4. The kubelet uses the `systemd` cgroup driver (the container runtime uses systemd).
5. `kubeadm config validate` passes for the new file.

Constraints:
- Do not run `kubeadm init` and do not change the cluster.
- Keep the node name, Kubernetes version and every other setting of the original.
