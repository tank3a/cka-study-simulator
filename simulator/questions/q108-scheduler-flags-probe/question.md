**Context:** `kubectl config use-context {{context}}`

The Deployment `sched-flag-test` in namespace `{{namespace}}` has two replicas, but both Pods stay `Pending` without any scheduling events.
Nobody changed the scheduler image or its kubeconfig.

Find the root cause(s) on the control plane node (`ssh {{host}}`) and fix them, so that both replicas become `Running` and
the `kube-scheduler` Pod is `Ready` (`1/1`).

Constraints:
- Do not set `nodeName` on the Pods and do not start a second scheduler.
- Do not delete the Deployment.
- Edit the existing static pod manifest in `/etc/kubernetes/manifests` and keep the file there.
