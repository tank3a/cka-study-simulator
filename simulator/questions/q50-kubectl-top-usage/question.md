**Context:** `kubectl config use-context {{context}}`

Namespace `{{namespace}}` runs several workloads and the nodes feel slow. Use the metrics API (`kubectl top`; create `/home/candidate/q50/` if needed):

1. Write the name of the Pod in `{{namespace}}` with the highest **CPU** usage to `/home/candidate/q50/top-cpu-pod.txt` (only the pod name).
2. Write the name of the Pod in `{{namespace}}` with the highest **memory** usage to `/home/candidate/q50/top-mem-pod.txt` (only the pod name).
3. Save the node usage table (`kubectl top` for nodes, all nodes) to `/home/candidate/q50/nodes.txt`.
4. The Deployment owning the highest-CPU pod must be capped: set its CPU limit to `150m` (keep the request at or below the limit).

Constraints:
- Do not delete any workload and do not change replicas.
- Metrics may take up to a minute to appear after the pods start; if `kubectl top` says "metrics not available yet", wait and retry.
