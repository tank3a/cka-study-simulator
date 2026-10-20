Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The Deployment `web` in namespace `{{namespace}}` serves a public website and must scale with load.

Create a HorizontalPodAutoscaler named `web-hpa` that:
- targets the Deployment `web`
- keeps between `2` and `8` replicas
- scales on average CPU utilization of `60%`
- waits `30` seconds (stabilization window) before scaling down

The autoscaler must be able to read the metric: its current CPU value must not be `<unknown>`.
You may change the Deployment's Pod template if needed, but keep its name, image and labels.
