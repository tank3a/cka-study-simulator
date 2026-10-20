Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

1. Write the names of all nodes that currently have a taint with effect `NoSchedule`, one per line,
   to `/home/candidate/noschedule-nodes.txt` (on this terminal host).
2. The Deployment `cp-monitor` in namespace `{{namespace}}` must run **only on the control-plane node**.
   Modify it so that its Pods are scheduled there (use a nodeSelector on the standard control-plane node label and
   add the toleration that is required). Do not remove or change any taint on the nodes.
3. Label the node `k8s-worker` with `disk=ssd`. Then modify the Deployment `fast-store` so its Pods are scheduled
   only on nodes carrying the label `disk=ssd`.
4. Add the taint `team=blue:PreferNoSchedule` to the node `k8s-worker2`.

Both Deployments must finish their rollout. Do not delete the Deployments.
