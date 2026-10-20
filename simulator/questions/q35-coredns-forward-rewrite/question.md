You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The cluster DNS is CoreDNS (ConfigMap `coredns` in `kube-system`). Change its configuration as follows:

1. All queries for names in the zone `corp.internal` must be forwarded to the company DNS server that runs as the Service
   `corp-dns` in namespace `dns-lab` (use the ClusterIP of that Service, port 53).
2. Queries for the name `old-db.example.org` must be answered with the records of the Service
   `db.dns-lab.svc.cluster.local` (rewrite the name).
3. Everything that works today (for example `kubernetes.default.svc.cluster.local` and the upstream forwarding for other names)
   must keep working. CoreDNS must stay healthy.

You can verify with the Pod `dnsclient` in namespace `dns-lab`, for example
`kubectl -n dns-lab exec dnsclient -- nslookup app.corp.internal`.
