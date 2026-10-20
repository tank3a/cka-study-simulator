Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

The etcd of this cluster runs as a static Pod on the control plane node. Before a maintenance window you must back it up.

1. Create a snapshot of the cluster's etcd and save it as `/opt/cka/etcd-backup.db` on the control plane node.
2. Verify the snapshot with the etcd utility and make sure it is valid.
3. Write the number of members of the etcd cluster (a single number) to `/opt/cka/etcd-members.txt`.

Constraints:
- Use the client certificates and endpoint the running etcd is configured with (look at its static Pod manifest).
- Do not stop, restart or modify etcd or any control plane component.
