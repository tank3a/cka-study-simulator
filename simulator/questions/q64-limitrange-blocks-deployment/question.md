Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The Deployment `worker` (2 replicas, containers `app` and `cache`) in namespace `{{namespace}}` has no Pods: its ReplicaSet cannot create them.

1. Find out why and fix the **Deployment** so that both replicas run. The LimitRange in the namespace is a company policy: do not modify or delete it,
   and keep each container's limits as close to what it asked for as the policy allows (do not simply remove the limits).
2. Create a PersistentVolumeClaim `worker-data` (ReadWriteOnce, `1Gi`, default StorageClass) in the same namespace.
   Use `kubectl describe limitrange` to check that its size is allowed.
