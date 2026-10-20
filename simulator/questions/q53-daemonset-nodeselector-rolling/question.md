Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The node `k8s-worker` is labelled `disk=ssd`. Create a DaemonSet named `log-agent` in namespace `{{namespace}}` that:

- uses image `busybox:1.37` with command `sleep 3600`, container name `agent`, Pod label `app=log-agent`
- runs **only** on nodes labelled `disk=ssd`
- mounts the host directory `/var/log` **read-only** at `/host-logs` (use a `hostPath` volume)
- uses the `RollingUpdate` strategy with `maxUnavailable: 1`

The second worker `k8s-worker2` also has SSD storage: make `log-agent` run there as well, without editing the DaemonSet again.
No Pod of the DaemonSet may run on the control-plane node.
