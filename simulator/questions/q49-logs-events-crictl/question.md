**Context:** `kubectl config use-context {{context}}`

In namespace `{{namespace}}` there is the Pod `multi` (containers `collector` and `shipper`) and the Pod `crasher` that keeps restarting.
Collect the following information (create `/home/candidate/q49/` if needed):

1. The logs of container `shipper` of Pod `multi` -> `/home/candidate/q49/shipper.log` (only that container).
2. The logs of the **previous** (crashed) instance of Pod `crasher` -> `/home/candidate/q49/crasher-previous.log`.
3. All events of type `Warning` in namespace `{{namespace}}`, sorted by `.lastTimestamp` (oldest first), as shown by kubectl -> `/home/candidate/q49/warnings.txt`.
4. The current CPU/memory usage of the containers of Pod `multi` (one line per container) -> `/home/candidate/q49/top.txt`.
5. Pod `multi` runs on node `k8s-worker` (`ssh {{host}}`). On that node, use `crictl` to find the **full container ID** of the running container `shipper` and write only that ID to `/opt/cka/q49-shipper-id.txt` (on the node; create the directory if needed, use `sudo`).

Do not restart or modify any Pod.
