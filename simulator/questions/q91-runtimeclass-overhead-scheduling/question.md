Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i`; only needed for step 1)

Node `k8s-worker` is reserved for sandboxed workloads and carries the label `runtime=sandbox`.

1. Find the OCI runtime handlers configured in containerd on `k8s-worker` (names under `containerd.runtimes` in `/etc/containerd/config.toml`) and write their names, one per line, to `/home/candidate/answers/q91-handlers.txt`.
2. Create a RuntimeClass `sandboxed` that uses the handler `runc`, adds a fixed Pod overhead of `100m` CPU and `32Mi` memory, and schedules Pods only on nodes with the label `runtime=sandbox`.
3. Create the Deployment `sbx` in namespace `{{namespace}}` (image `busybox:1.37`, command `sleep 3600`, 2 replicas) that runs with this RuntimeClass. Do not add a nodeSelector to the Deployment itself.

Constraints:
- Do not change the containerd configuration.
