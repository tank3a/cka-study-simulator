Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The worker nodes carry the labels `tier=app` and `zone=a` (`k8s-worker`) / `zone=b` (`k8s-worker2`).

1. Modify the Deployment `web-tier` (2 replicas) so that its Pods are scheduled with these rules:
   - **required** node affinity: only nodes with label `tier` in (`app`)
   - **preferred** node affinity (weight `80`): nodes with label `zone=a`
   - **required** pod anti-affinity: no two Pods labelled `app=web-tier` may run on the same node (`kubernetes.io/hostname`)

2. The DaemonSet `node-agent` must run on **every** node of the cluster, including the control-plane node.
   Modify it accordingly without removing any taint from the nodes.

3. Create a PriorityClass `batch-low` with value `100` that never preempts other Pods (`preemptionPolicy: Never`),
   and make the Deployment `report-gen` use it.

All three workloads must finish their rollout.
