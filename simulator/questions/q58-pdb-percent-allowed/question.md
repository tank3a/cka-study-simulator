Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The Deployment `api` (4 replicas, label `app=api`) in namespace `{{namespace}}` must survive voluntary disruptions such as node drains.

1. Create a PodDisruptionBudget `api-pdb` in namespace `{{namespace}}` that selects the Pods of `api` and guarantees that at least `75%` of them stay available.
2. Write the number of currently allowed disruptions reported by the PodDisruptionBudget (only the number) into `/home/candidate/q58.txt` on the terminal host.
