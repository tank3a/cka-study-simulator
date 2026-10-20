Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The Deployment `sizing-target` in namespace `{{namespace}}` has no good resource requests yet. The team wants VerticalPodAutoscaler
**recommendations only**, without Pods ever being evicted or modified.

Create a VerticalPodAutoscaler `sizing-vpa` in namespace `{{namespace}}` that:

- targets the Deployment `sizing-target`
- never applies recommendations (update mode that only computes them)
- for the container `app`: minimum `cpu: 50m, memory: 64Mi`, maximum `cpu: 500m, memory: 512Mi`, and controls both `cpu` and `memory`

Note: the VPA components are not fully available in this lab (a stand-in CRD may be used), so no recommendations will appear; this task is graded on the API object only.
