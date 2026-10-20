You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The Deployment `api` (2 replicas) is healthy, but clients in the namespace get "connection refused" or time out when they call
`http://api` (Service `api`, port 80).

1. Find out why and fix the Service `api` so that `http://api` works from the Pod `client`.
   - Only change the Service. Do **not** edit, scale, relabel or recreate the Deployment or its Pods.
2. Write the IP addresses of all Pods that now back the Service `api` (taken from its EndpointSlice), one IP per line, to
   `/home/candidate/api-endpoints.txt`.
