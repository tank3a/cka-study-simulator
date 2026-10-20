**Context:** `kubectl config use-context {{context}}`

In namespace `{{namespace}}` the Services `shop-api` and `shop-web` do not answer requests from other pods (use the pod `tester` Deployment for your tests).

Find out why and repair the **Services** so that:
- `curl`/`wget` to `http://shop-api` (port 80) returns the nginx welcome page.
- `curl`/`wget` to `http://shop-web` (port 80) returns `shop-web`.

Constraints:
- Do not modify, restart or re-create the Deployments (labels and container ports are owned by another team).
- Keep the Service names, types (`ClusterIP`) and port 80.
