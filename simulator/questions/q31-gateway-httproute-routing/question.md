You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

A Gateway named `web-gw` (GatewayClass `nginx`, HTTP listener on port 80) already exists in the namespace, together with
two applications: Service `app-v1` and Service `app-v2` (both port 80).

Create an HTTPRoute named `app-route` in namespace `gw-route` that is attached to the Gateway `web-gw`, for the hostname
`app.example.com`, with these rules:

1. Requests with path prefix `/v1` go to Service `app-v1`.
2. Requests with path prefix `/v2` go to Service `app-v2`.
3. All other requests go to Service `app-v1`, **except** requests that carry the HTTP header `X-Env: canary`
   (exact match) and do not match rule 1 or 2: these go to Service `app-v2`.

Do not modify the Gateway or the Services.
