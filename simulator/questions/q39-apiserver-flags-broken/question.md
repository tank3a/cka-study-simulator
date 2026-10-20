**Context:** `kubectl config use-context {{context}}`

After a maintenance window `kubectl` on this cluster only prints
`The connection to the server ek8s-control-plane:6443 was refused`.

Connect to the control plane node (`ssh {{host}}`), find out why the API server does not run and repair it.
When you are done, `kubectl get nodes` must work and all control plane pods in `kube-system` must be `Running`.

Constraints:
- Do not re-install or re-initialise the cluster (no `kubeadm init/reset`).
- Keep all existing cluster data (namespace `apiserver-fix` must still exist).
- Edit only what is broken; do not move the manifest out of `/etc/kubernetes/manifests`.
