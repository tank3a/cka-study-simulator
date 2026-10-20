**Context:** `kubectl config use-context {{context}}`

In namespace `{{namespace}}` the Deployment `client` must call the Service `backend` by name (`http://backend`).
Since a security hardening (NetworkPolicy `client-egress`) the call fails with `bad address 'backend'`.

Repair the situation so that:
- `client` can resolve names and reach `http://backend` (port 80).
- `client` still **cannot** reach the Service `intruder` (same namespace, port 80).

Constraints:
- Keep the policy type `Egress` restrictive: no `egress: [{}]` (allow-all) and no `ipBlock: 0.0.0.0/0`.
- Do not modify the Deployments or Services.
