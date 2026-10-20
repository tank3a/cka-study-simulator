Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

An engineer deleted data by mistake. A snapshot taken before the incident exists at `/opt/cka/etcd-snapshot-prev.db` on the control plane node.

1. Restore the snapshot into the new data directory `/var/lib/etcd-restore`.
2. Make the etcd static Pod use the restored data. The cluster must come back healthy.
3. Afterwards, Deployment `restore-keep` must exist in namespace `{{namespace}}` and Deployment `restore-drop` (created after the snapshot) must not.

Constraints:
- Do not delete or overwrite the old data directory `/var/lib/etcd`.
- Do not create a new snapshot over `/opt/cka/etcd-snapshot-prev.db`.
- The API server will be unavailable while etcd restarts: be patient and check with `crictl ps`.
