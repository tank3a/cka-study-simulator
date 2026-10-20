**Context:** `kubectl config use-context {{context}}`

A colleague prepared a static pod `audit-agent` for the node `k8s-worker` (ssh alias `k8s-node1`) in namespace `{{namespace}}`,
but no such pod shows up in the cluster. The manifest file is `audit-agent.yaml` somewhere under `/etc/kubernetes` on that node.

Make the static pod run: the mirror pod `audit-agent-k8s-worker` must be `Running` in namespace `{{namespace}}`.

Constraints:
- It must remain a static pod, managed by the kubelet. Do not create a Deployment, DaemonSet or a normal Pod instead.
- Do not change the kubelet configuration.
- Keep the pod name `audit-agent`, the namespace and the container name `agent`.
