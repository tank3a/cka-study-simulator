Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The Deployment `shipper` in namespace `{{namespace}}` runs the container `app`, which writes its log to
`/var/log/app/app.log` on the shared emptyDir volume `logs`.

Add a logging sidecar to the Deployment's Pod template as a **native sidecar container** (a container that starts
before `app` and keeps running for the whole Pod lifetime):

- name `log-agent`, image `busybox:1.37`
- command `tail -F /var/log/app/app.log`
- mounts the volume `logs` at `/var/log/app` (read-only)
- mounts the existing ConfigMap `agent-config` at `/etc/agent`
- resource limits: cpu `50m`, memory `32Mi`

Keep the existing container `app` and its volume unchanged. All Pods of `shipper` must become Ready.
