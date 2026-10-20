You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The Deployment `sticky` (3 replicas) answers every HTTP request with its own Pod name. A Service `sticky` (ClusterIP, port 80) exists, but requests from the Pod `tester` are spread over all three Pods, which breaks the application's sessions.

1. Change the existing Service `sticky` so that all requests from the same client IP go to the same Pod for **10 minutes** (600 seconds). Do not recreate the Service.
2. From the Pod `tester`, send 10 requests to `http://sticky` and write the number of **distinct** Pod names that answered into `/home/candidate/affinity.txt` (just the number).

Do not modify the Deployment or the Pod `tester`.
