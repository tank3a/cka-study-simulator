You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

A Deployment named `shop` (2 replicas, container port 80) is already running in the namespace.

1. Create a Service named `shop-lb` that publishes the Pods of Deployment `shop` through an external load balancer.
   - Type `LoadBalancer`, Service port `80`, target port `80`.
   - The load balancer must only accept clients from the range `10.0.0.0/8`.
   - Traffic that arrives on a node must be sent **only to Pods on that same node** (the client source IP must be preserved).
2. Write the `nodePort` that Kubernetes allocated for `shop-lb` into the file `/home/candidate/shop-lb-nodeport.txt` (just the number).

The cluster has no cloud load balancer, so a pending EXTERNAL-IP is expected. Do not modify the Deployment.
