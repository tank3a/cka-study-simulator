You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The Services `green` and `blue` (both port 80) and a TLS Secret `site-tls` already exist in the namespace.
An IngressClass named `nginx` is available.

Create an Ingress named `site` in namespace `ing-lab` with these properties:

- `ingressClassName: nginx`
- host `site.example.com`
- path `/green` (pathType `Prefix`) -> Service `green`, port 80
- path `/blue` (pathType `Prefix`) -> Service `blue`, port 80
- TLS enabled for host `site.example.com` using the Secret `site-tls`

Do not modify the Services or the Secret.
