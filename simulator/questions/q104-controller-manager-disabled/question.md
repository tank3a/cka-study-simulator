**Context:** `kubectl config use-context {{context}}`

In namespace `{{namespace}}` the Deployment `rs-test` (2 replicas) has a ReplicaSet, and the Job `batch-test` exists, but
neither of them ever creates a Pod. `kube-controller-manager` itself is reported `Running` and `Ready`, and nothing crashes.

Find the cause on the control plane node (`ssh {{host}}`) and fix it, so that `rs-test` has 2 available replicas and
`batch-test` completes.

Constraints:
- Do not delete or recreate the Deployment or the Job and do not create Pods by hand.
- Do not add or remove any other kube-controller-manager flag than the one causing the problem.
