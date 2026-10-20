You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The Service `api` (type `NodePort`, port `8080` -> `80`, nodePort `30091`) fronts the Deployment `api`. Clients already use node port `30091`, so the Service must **not be deleted or recreated**.

1. Change the existing Service `api` to type `LoadBalancer`.
   - Keep nodePort `30091` and the ports unchanged.
   - Set the traffic policy so that traffic is not forwarded to Pods on other nodes (`Local`).
2. A cloud load balancer checks the health of each node on a dedicated port. Write that health check port number, as allocated by Kubernetes for this Service, into `/home/candidate/hc-port.txt` (just the number).

Do not modify the Deployment `api`.
