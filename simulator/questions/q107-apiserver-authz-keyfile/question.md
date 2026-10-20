**Context:** `kubectl config use-context {{context}}`

After a maintenance window `kubectl` against this cluster only prints `The connection to the server ... was refused`.
Connect to the control plane node (`ssh {{host}}`), find out why the `kube-apiserver` does not come up and repair it.

Constraints:
- Only edit the existing static pod manifest in `/etc/kubernetes/manifests`; keep the file name and location.
- Do not touch etcd, its data, or any certificate files; the certificates on disk are correct.
- The cluster must be fully working afterwards (`kubectl get nodes` shows all nodes Ready, namespace `apiserver-fix2` still exists).
