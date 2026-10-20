You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The Pod `client` (label `app=client`) runs in namespace `egress-lab`. Namespace `egress-data` runs two backends:
Service `db` (Pods `app=db`) and Service `cache` (Pods `app=cache`), both on TCP port 80.

Create a NetworkPolicy named `client-egress` in namespace `egress-lab` that applies to the Pods labelled `app=client` and
restricts their **egress** traffic so that they can only:

- connect to Pods labelled `app=db` in the namespace `egress-data` on TCP port 80, and
- send DNS queries (UDP **and** TCP port 53) to the cluster DNS Pods in `kube-system` (label `k8s-app=kube-dns`).

All other egress from these Pods must be denied. Do not use `ipBlock`, and do not modify the existing Pods, Services or namespaces.
