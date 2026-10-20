Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The VerticalPodAutoscaler `web-vpa` in namespace `{{namespace}}` was meant to right-size the Deployment `web`, which has two containers
(`web` and `log-sidecar`), but it does not select anything useful. Fix the **existing** VPA in place (do not delete it) so that:

1. it targets the Deployment `web`
2. recommendations are applied only when Pods are (re)created, never by evicting running Pods
3. the container `web` is managed for `requests` only (the VPA must not touch its limits)
4. the container `log-sidecar` is excluded from autoscaling completely

Note: the VPA components are not fully available in this lab (a stand-in CRD may be used); the task is graded on the API object only.
