**Context:** `kubectl config use-context {{context}}`

`kubectl top` reports that the metrics API is unavailable, although the `metrics-server` Pod in `kube-system` is `Running` and `Ready`
(create `/home/candidate/q106/` if needed):

1. Find and fix the misconfiguration so that `kubectl top nodes` and `kubectl top pods -A` work again.
2. Write the misconfigured object as `kind/name` (lower-case, e.g. `deployment/foo`) to `/home/candidate/q106/cause.txt`.
3. Save the output of `kubectl top pods -n kube-system --containers` to `/home/candidate/q106/pods-top.txt`.

Constraints:
- Do not delete the Deployment or the APIService, and do not edit the metrics-server container args.
- The APIService must keep pointing at Service `metrics-server` in `kube-system`.
