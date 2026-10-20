**Context:** `kubectl config use-context {{context}}`

Pods in the cluster can no longer resolve Service names. In namespace `{{namespace}}` the pod `client` (Deployment) cannot reach
`http://web.dns-fix.svc.cluster.local`, and name resolution of external names is unreliable as well.

1. Find and fix the cause. The cluster DNS must keep forwarding unknown names to the resolv.conf of the node.
2. When it works, save the output of `nslookup web.dns-fix.svc.cluster.local` run **inside the `client` pod** to `/home/candidate/q46/nslookup.txt`.

Constraints:
- Do not change the Service `web`, the Deployments in `{{namespace}}` or the kubelet configuration.
- Do not replace CoreDNS by another DNS server; fix the configuration of the existing one.
- Keep CoreDNS running with all its replicas.
