You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

A Deployment named `web` (3 replicas) is already running in the namespace.

1. Create a Service named `web-svc` that exposes the Pods of Deployment `web` to the outside of the cluster.
   - Type `NodePort`, Service port `80`, target port `80`, and the fixed `nodePort` `30080`.
2. Create a second Service named `web-internal` that is reachable **only inside** the cluster.
   - Type `ClusterIP`, Service port `8080`, target port `80`.
3. Both Services must select the Pods of the Deployment through their labels.

Do not modify the Deployment `web` or the Pod `tester`.
