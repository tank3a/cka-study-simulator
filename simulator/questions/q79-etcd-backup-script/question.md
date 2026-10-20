Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

The team wants a repeatable backup of etcd. The etcd of this cluster is a static Pod on the control plane node.

1. Create the executable bash script `/opt/cka/etcd-backup.sh`. It takes the snapshot file path as its **first argument** (`$1`), saves an etcd snapshot to that path with the endpoint and certificates the running etcd uses, and exits with an error if no argument is given or the save fails.
2. Run the script once with `/opt/cka/backups/etcd-snap.db` (create the directory).
3. Write the status of that snapshot as **JSON** (revision, hash, total keys) to `/opt/cka/etcd-snap-status.json`.
4. Write the table output of the etcd endpoint status (it shows the leader) to `/opt/cka/etcd-endpoint-status.txt`.

Constraints:
- Do not stop, restart or modify etcd or any control plane component.
- The script must work for any file path, not only the one used in step 2.
