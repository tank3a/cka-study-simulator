**Context:** `kubectl config use-context {{context}}`

Namespace `{{namespace}}` runs three tiers: `web`, `api` and `db` (Deployments with label `app=<tier>`, all listen on port 80).
A default-deny ingress policy is in place. The application is broken: `web` cannot call `api` and `api` cannot call `db`.

Fix the connectivity using NetworkPolicies in `{{namespace}}`, so that exactly this is allowed:
- `web` -> `api` on TCP 80
- `api` -> `db` on TCP 80

and this stays blocked:
- `web` -> `db`
- everything from other namespaces (e.g. the pod `probe` in namespace `np-other`) to `api` and `db`

Constraints:
- Do not delete the policy `deny-all-ingress`.
- Do not modify the Deployments or their labels.
- Do not use `ipBlock` and do not open ports other than TCP 80.
