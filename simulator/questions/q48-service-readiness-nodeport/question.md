**Context:** `kubectl config use-context {{context}}`

The application `portal` in namespace `{{namespace}}` (Deployment, 2 replicas, nginx) is published through the NodePort Service `portal` (nodePort `30048`),
but requests to `http://<node-ip>:30048/` are refused or time out.

Find and fix **all** causes so that the Service has two ready endpoints and answers with HTTP 200 on every node at port 30048.

Constraints:
- Keep the Service name, type, `nodePort: 30048` and the Deployment name.
- The readiness probe must stay in place (do not delete it), and the Service must keep using a *named* targetPort.
