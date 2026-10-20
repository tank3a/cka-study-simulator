Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The cluster already has user-defined PriorityClasses (for example `platform-high`, `team-mid`).
The Deployment `checkout` in namespace `{{namespace}}` is business critical but runs with no priority and no resource settings.

1. Create a new PriorityClass named `business-critical` whose value is exactly **one less than the highest existing
   user-defined PriorityClass** (do not count the system classes `system-cluster-critical` and `system-node-critical`).
   It must not be the global default and must have the description `Business critical workloads`.
2. Configure the Deployment `checkout` so its Pods use `business-critical`.
3. Set the container `checkout` resources:
   requests cpu `100m`, memory `64Mi`; limits cpu `200m`, memory `128Mi`.

All Pods of `checkout` must be Running afterwards. Do not modify the existing PriorityClasses.
