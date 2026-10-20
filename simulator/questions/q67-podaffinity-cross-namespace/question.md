Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

In namespace `{{namespace}}` run the Deployment `cache` (1 replica, label `app=cache`) and the Deployment `frontend` (2 replicas, label `app=frontend`).
The namespace `aff2-batch` runs noisy batch Pods labelled `app=batch-noisy` on the node `k8s-worker`.

Change the Deployments so that, after their rollouts:

1. `cache` must **never** be scheduled onto a node that runs a Pod labelled `app=batch-noisy` from the namespace `aff2-batch` (hard rule, per node).
2. `frontend` Pods must **always** be scheduled onto the same node as a `cache` Pod (hard rule, per node, Pods of namespace `{{namespace}}`).

The final placement must satisfy both rules for the running Pods. Do not use `nodeName`, `nodeSelector` or taints/tolerations, and do not touch the `aff2-batch` namespace.
