Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

A bad script deleted objects. A snapshot taken **before** the incident is at `/opt/cka/etcd-pre-incident.db` on the control plane node.

Restore the cluster state from it **in place**: the etcd data directory must stay `/var/lib/etcd`, and the etcd static Pod manifest must **not** be edited.

1. Stop etcd by moving its manifest out of the manifests directory (to `/opt/cka/etcd.yaml.disabled`), and wait until the etcd container is gone.
2. Keep the damaged data: rename `/var/lib/etcd` to `/var/lib/etcd.old`.
3. Restore the snapshot into a new `/var/lib/etcd`.
4. Put the manifest back unchanged. Wait until the cluster is healthy.
5. Afterwards Deployment `ledger-keep` must exist in namespace `{{namespace}}` and `ledger-drop` (created after the snapshot) must not.

Constraints:
- Do not delete `/var/lib/etcd.old`.
- Do not create a new snapshot over `/opt/cka/etcd-pre-incident.db`.
