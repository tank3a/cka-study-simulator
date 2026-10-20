You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The Services `web`, `api` and `fallback` (all port 80) exist in the namespace. An IngressClass named `nginx` is available.

Create an Ingress named `portal` in namespace `ing-def`:

- `ingressClassName: nginx`
- a **default backend**: Service `fallback`, port 80 (answers requests that match no rule)
- one rule for the wildcard host `*.portal.example.com` with two paths:
  - `/api` with pathType `Exact` -> Service `api`, port 80
  - `/` with pathType `Prefix` -> Service `web`, port 80

No TLS is required. Do not modify the Services.
