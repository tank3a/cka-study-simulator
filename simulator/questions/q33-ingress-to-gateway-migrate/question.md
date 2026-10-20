You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The namespace still uses an old Ingress named `legacy` (read it with `kubectl -n legacy-ing get ingress legacy -o yaml`).
The company is migrating to the Gateway API. A Gateway named `main-gw` (GatewayClass `nginx`, HTTP listener on port 80)
already exists in the namespace.

1. Create an HTTPRoute named `legacy-route` in namespace `legacy-ing`, attached to the Gateway `main-gw`, that reproduces
   **exactly the same host and path routing** as the Ingress `legacy` (same hostname, same paths, same backend Services and ports).
2. After the new route works, delete the Ingress `legacy`.

Do not modify the Gateway or the Services.
