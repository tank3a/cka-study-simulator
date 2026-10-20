You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

The Deployment `api` runs in namespace `shop-back` (Service `api`, port 80). A default-deny ingress policy
(`default-deny-ingress`) is already active in that namespace, so nothing can reach `api` at the moment.

The frontend Pod `web` (label `role=frontend`) runs in namespace `shop-front`. Other Pods exist in `shop-front`
(for example `batch`, label `role=batch`) and in the namespace `shop-other`.

Three candidate NetworkPolicy manifests are provided on this terminal:

    /home/candidate/netpol/np-a.yaml
    /home/candidate/netpol/np-b.yaml
    /home/candidate/netpol/np-c.yaml

Inspect them and apply **exactly one**: the one that lets only the Pods labelled `role=frontend` in namespace
`shop-front` reach the `api` Pods on TCP port 80, and is the **least permissive** of the three that still does this.

Constraints:
- Do not edit the provided files and do not create any new NetworkPolicy of your own.
- Do not modify or delete the existing `default-deny-ingress` policy.
- Apply only the one chosen manifest.
