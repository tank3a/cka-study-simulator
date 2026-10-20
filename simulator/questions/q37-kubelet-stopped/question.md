**Context:** `kubectl config use-context {{context}}`

One worker node of this cluster is reported `NotReady`.

1. Find out which node is `NotReady` and save its name (only the name) to `/home/candidate/q37/notready-node.txt` on the machine you are working from.
2. Connect to that node (`ssh {{host}}`; the node object is named `ek8s-worker`), find the cause and repair it so that the node becomes `Ready` again.
3. The fix must survive a reboot of the node.

Constraints:
- Do not delete or re-create the node object.
- Do not touch the control plane node.
