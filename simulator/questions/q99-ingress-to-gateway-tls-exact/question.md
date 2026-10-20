You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The namespace contains the old Ingress `store` (read it with `kubectl -n mig-tls get ingress store -o yaml`), the Services `web` and `api` (port 80) and the TLS Secret `store-tls`.
Move the site to the Gateway API. The GatewayClass is named `nginx`.

1. Create a Gateway named `store-gw` in namespace `mig-tls` with one listener `https`: port `443`, protocol `HTTPS`, hostname taken from the Ingress, TLS terminated with the Secret named in the Ingress.
2. Create an HTTPRoute named `store-route`, attached to listener `https` of `store-gw`, that reproduces the **routing semantics** of the Ingress exactly. Pay attention to the path types of the Ingress: a request for `/api/v2` must NOT reach the `api` Service.
3. After the new route works, delete the Ingress `store`.

Do not modify the Services or the Secret.
