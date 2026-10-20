Context: `kubectl config use-context {{context}}`

Node `k8s-worker2` must be serviced. Workloads run in namespace `{{namespace}}`: Deployment `web` (4 replicas, each with an emptyDir volume), DaemonSet `agent` and the standalone Pod `solo` (no controller).

1. A colleague left `k8s-worker` unschedulable after earlier work. Check the nodes and make `k8s-worker` accept Pods again.
2. Evict all workloads from `k8s-worker2` so it can be serviced. Pods of the DaemonSet may stay. The standalone Pod `solo` may be deleted.
3. `k8s-worker2` must stay unschedulable (the maintenance has not finished yet).
4. At the end all 4 replicas of `web` must be available and run on `k8s-worker`.

Constraints:
- Do not delete the Deployment or the DaemonSet.
- Do not use `kubectl delete pod` for the Deployment's Pods; use the node maintenance commands.
