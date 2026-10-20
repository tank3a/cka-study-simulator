Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The team owning namespace `{{namespace}}` gets this budget:

- at most `4` Pods
- total requests: `1` CPU and `1Gi` memory
- total limits: `2` CPU and `2Gi` memory

1. Create a ResourceQuota `team-quota` in namespace `{{namespace}}` enforcing exactly this budget.
2. The existing Deployment `app` (3 replicas, no resources defined) must keep running with 3 replicas under the quota:
   modify it so each container has requests `cpu: 200m, memory: 128Mi` and limits `cpu: 400m, memory: 256Mi`, and wait for the rollout to finish.
