Context: `kubectl config use-context {{context}}`
Host: `{{host}}` for the control plane, `ssh ik8s-node1` for the worker.

The cluster runs Kubernetes v1.34.x. Upgrade it to the newest v1.35 patch release that `kubeadm upgrade plan` offers. The node package repository is already configured to offer v1.35 packages.

1. Upgrade the control plane node `ik8s-control-plane`: kubeadm, then the control plane components, then kubelet and kubectl.
2. Upgrade the worker node `ik8s-worker` the same way (kubeadm, kubelet, kubectl).
3. Both nodes must be schedulable again at the end and report the new kubelet version.

Constraints:
- Drain a node before you upgrade it and uncordon it afterwards. Ignore DaemonSets and delete emptyDir data when draining.
- Use `apt-get` for the packages. Do not hold back kubelet at v1.34.
- Do not upgrade to v1.36 or later.
