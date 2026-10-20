Context: `kubectl config use-context {{context}}`

The nodes of this cluster are `NotReady` because no CNI plugin is installed. The Calico manifest is `/home/candidate/manifests/calico.yaml` (do not edit this original).

1. Find the Pod network CIDR the cluster was created with (the value of `podSubnet` in the kubeadm configuration).
2. Make a copy `/home/candidate/manifests/calico-custom.yaml` in which the Calico IP pool (`CALICO_IPV4POOL_CIDR` of the `calico-node` container) is **set to that CIDR** (the setting is commented out in the original).
3. Apply the copy. Wait until all nodes are `Ready`.
4. Deployment `net-probe` in namespace `{{namespace}}` (2 replicas on different nodes) must become Running and its Pods must be able to reach each other.

Constraints:
- The Pod CIDR you configure must match the cluster's `podSubnet`.
