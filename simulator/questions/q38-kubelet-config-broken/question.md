**Context:** `kubectl config use-context {{context}}`

Node `k8s-worker2` (ssh alias `k8s-node2`) has been `NotReady` for a while, although the machine itself is up.
A pod `canary` in namespace `kubelet-fix` is supposed to run on this node.

Investigate on the node, repair the kubelet and bring the node back to `Ready`.
The pod `canary` must be `Ready` again afterwards.

Constraints:
- Do not delete, drain or re-join the node.
- Do not re-create the pod `canary`.
- There may be more than one problem.
