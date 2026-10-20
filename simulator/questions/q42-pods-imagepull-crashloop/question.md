**Context:** `kubectl config use-context {{context}}`

After a release, three Deployments in namespace `{{namespace}}` are unhealthy: `web`, `api` and `cache`.
Find the reason for each and repair them so that every Deployment has all replicas `Ready` and stays stable.

Facts you need:
- `web` must run the image `nginx:1.27`.
- `api` needs the environment variable `DB_HOST=postgres.outage.svc.cluster.local`.
- `cache` is an nginx container that listens on port 80.

Constraints:
- Do not change the replica counts and do not delete the Deployments.
- Do not create additional Deployments or Pods.
