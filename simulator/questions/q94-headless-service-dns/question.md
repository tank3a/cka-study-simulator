You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

A StatefulSet named `db` (3 replicas, label `app=db`, `serviceName: db-hl`) is running, but its governing Service does not exist yet, so the Pods have no stable DNS names. A Pod named `tester` can be used for lookups.

1. Create a **headless** Service named `db-hl` for the Pods of StatefulSet `db` (port `80`, target port `80`).
2. From the Pod `tester`, look up the name `db-hl`. Write the number of A records returned into `/home/candidate/hl-count.txt` (just the number).
3. Write the fully qualified DNS name of the Pod `db-1` (as published through `db-hl`, cluster domain `cluster.local`) into `/home/candidate/hl-pod.txt`.

Do not modify the StatefulSet or the Pod `tester`.
