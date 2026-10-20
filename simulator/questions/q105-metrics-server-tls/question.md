**Context:** `kubectl config use-context {{context}}`

`kubectl top nodes` fails with an error about the metrics API. Restore the resource metrics pipeline (create `/home/candidate/q105/` if needed):

1. Find out why the metrics API `v1beta1.metrics.k8s.io` is not available and fix the cause in the existing `metrics-server` Deployment in `kube-system`.
2. Write the one-line root cause as the flag name that is missing, e.g. `--some-flag`, to `/home/candidate/q105/cause.txt`.
3. When `kubectl top nodes` works again, save its output (with header) to `/home/candidate/q105/nodes.txt`.

Constraints:
- Do not delete the Deployment, the Service or the APIService.
- Metrics need up to a minute to appear after a restart of metrics-server.
