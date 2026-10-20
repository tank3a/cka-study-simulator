Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The platform team wants to drain the worker nodes next week, but `kubectl drain` would hang on the Deployment `critical`
(2 replicas) in namespace `{{namespace}}`, because its PodDisruptionBudget `critical-pdb` currently allows **no** disruption.

Change the existing PodDisruptionBudget `critical-pdb` (do not delete it, do not change the Deployment, do not drain any node) so that:

1. at most **one** Pod of `critical` may be voluntarily disrupted at any time (use `maxUnavailable`)
2. Pods that are not Ready can always be evicted (`unhealthyPodEvictionPolicy: AlwaysAllow`)

The PodDisruptionBudget must report `1` allowed disruption afterwards.
