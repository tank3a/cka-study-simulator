Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The Deployment `spread-app` in namespace `{{namespace}}` (4 replicas, label `app=spread-app`) must be spread **evenly** over the worker nodes:
exactly 2 Pods on `k8s-worker` and 2 on `k8s-worker2`, none on the control-plane node.
The current configuration spreads nothing reliably. Fix the Deployment so that:

- the spread uses the topology key `kubernetes.io/hostname`
- the difference in Pod count between nodes may be at most `1`, and a Pod that would break this is **not** scheduled (it must wait)
- the constraint counts only the Pods of this Deployment
- all 4 replicas become Running

Do not use `nodeName`, `nodeSelector`, affinity or change taints on any node.
