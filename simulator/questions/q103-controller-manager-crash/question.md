**Context:** `kubectl config use-context {{context}}`

In namespace `{{namespace}}` the Deployment `cm-test` (3 replicas) was created, but it has `0/3` ready replicas and no
ReplicaSet exists for it. Scheduling and the API server work normally.

Find the root cause on the control plane node (`ssh {{host}}`) and fix it, so that all 3 replicas of `cm-test` become available.

Constraints:
- Do not delete or recreate the Deployment, and do not create ReplicaSets or Pods by hand.
- Fix the existing static pod manifest in `/etc/kubernetes/manifests`; do not move or rename it.
