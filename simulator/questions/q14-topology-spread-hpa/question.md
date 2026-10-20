Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The worker nodes are labelled with `zone=a` (`k8s-worker`) and `zone=b` (`k8s-worker2`).
The Deployment `api` in namespace `{{namespace}}` runs 4 replicas.

1. Make the Pods of `api` spread evenly over the zones:
   `maxSkew: 1`, topology key `zone`, `whenUnsatisfiable: DoNotSchedule`, selecting the Pods labelled `app=api`.
2. Change the update strategy of `api` to `RollingUpdate` with `maxSurge: 1` and `maxUnavailable: 1`.
3. Set a CPU request of `50m` on the container, then create a HorizontalPodAutoscaler `api-hpa` for `api`:
   min `4`, max `6` replicas, target average CPU utilization `80%`.

After the changes each zone must run exactly 2 Pods of `api`, and the rollout must be complete.
