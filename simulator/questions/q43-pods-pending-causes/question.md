**Context:** `kubectl config use-context {{context}}`

In namespace `{{namespace}}` three workloads are `Pending`: Deployment `big-app`, Deployment `reporter` and Pod `db`.
Find out why each one is not scheduled and fix it.

Requirements:
- `big-app` (2 replicas) must run. Its container needs at most `250m` CPU; you may keep the memory request.
- `reporter` pods must run on node `k8s-worker`. The node is reserved and tainted on purpose: **do not remove the taint** and **do not change the nodeSelector** of the Deployment.
- Pod `db` must run and use the PersistentVolumeClaim `db-data` (1Gi, ReadWriteOnce). `db-data` must end up `Bound`. The claim name, size and access mode must stay the same.

Constraints:
- Do not scale down or delete `big-app` and `reporter`.
- Do not modify any other node property than what is needed.
