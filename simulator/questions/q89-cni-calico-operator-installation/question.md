Context: `kubectl config use-context {{context}}`

The nodes of this cluster are `NotReady` because no CNI plugin is installed. The operator-based Calico install files are in `/home/candidate/manifests`: `tigera-operator.yaml` (the operator; depending on the version it may also contain CRDs) and `custom-resources.yaml` (an `Installation` resource with the default IP pool CIDR `192.168.0.0/16`).

1. Install the Tigera operator from `tigera-operator.yaml`. (Hint: if `apply` fails with an annotation-too-long error because of large CRDs, use `create` or `apply --server-side`.)
2. Change `custom-resources.yaml` so that the IP pool CIDR of the `Installation` is the cluster's Pod network CIDR (`podSubnet` of the kubeadm configuration) and apply it.
3. Wait until the operator reports Calico available and all nodes are `Ready`.
4. Deployment `net-probe` in namespace `{{namespace}}` must run on 2 different nodes and its Pods must reach each other.

Constraints:
- The `Installation` named `default` must exist and use the cluster's Pod CIDR.
