You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The namespace contains the Service `shop` (port 80) and a TLS Secret `shop-tls` (certificate for `shop.example.com`).
The GatewayClass is named `nginx`.

1. Create a Gateway named `shop-gw` in namespace `gw-tls` with two listeners:
   - `https`: port `443`, protocol `HTTPS`, hostname `shop.example.com`, TLS terminated with the Secret `shop-tls`.
   - `http`: port `80`, protocol `HTTP`, hostname `shop.example.com`.
2. Create an HTTPRoute named `shop-route`, attached **only** to the listener `https` of `shop-gw`, that sends all
   traffic for `shop.example.com` to Service `shop` port 80.
3. Create an HTTPRoute named `shop-redirect`, attached **only** to the listener `http` of `shop-gw`, that answers every
   request for `shop.example.com` with a permanent redirect (status `301`) to the `https` scheme.

Do not modify the Service or the Secret.
