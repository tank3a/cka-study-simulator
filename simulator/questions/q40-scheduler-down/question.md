**Context:** `kubectl config use-context {{context}}`

The Deployment `sched-test` in namespace `{{namespace}}` has two replicas, but both Pods stay `Pending` and
`kubectl describe pod` shows no scheduling events at all.

Find the root cause on the control plane node (`ssh {{host}}`) and fix it, so that both replicas become `Running`.

Constraints:
- Do not set `nodeName` on the Pods and do not start a second scheduler.
- Do not delete the Deployment.
- The fix must be done in the existing static pod manifest; keep the file in `/etc/kubernetes/manifests`.
