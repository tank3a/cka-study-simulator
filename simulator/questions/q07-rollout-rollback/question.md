Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The Deployment `web` in namespace `{{namespace}}` (4 replicas) was just updated and the new rollout is stuck.

1. Roll back `web` to the last working revision.
2. Change the update strategy of `web` to `RollingUpdate` with `maxSurge: 2` and `maxUnavailable: 0`.
3. Update the container image of `web` to `nginx:1.27-alpine`. Before the update, annotate the Deployment with
   `kubernetes.io/change-cause="upgrade to alpine"` so the cause is recorded in the history.
   Wait until the rollout is complete (all 4 replicas updated and available).
4. Save the output of the rollout history of `web` to `/home/candidate/web-history.txt` (on this terminal host).

Do not delete the Deployment.
