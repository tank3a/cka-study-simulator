Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

The team plans a highly available control plane with an **external** etcd cluster of three members behind a load balancer for the API server.

1. Write the kubeadm `ClusterConfiguration` for the first control plane node to `/opt/cka/ha-external-etcd.yaml` with:
   - Kubernetes version `v1.34.0`;
   - `controlPlaneEndpoint` `lb.ha.example.com:6443`;
   - external etcd endpoints `https://10.0.0.11:2379`, `https://10.0.0.12:2379`, `https://10.0.0.13:2379`;
   - etcd CA `/etc/kubernetes/pki/etcd/ca.crt`, client certificate `/etc/kubernetes/pki/apiserver-etcd-client.crt`, client key `/etc/kubernetes/pki/apiserver-etcd-client.key`.
   The file must pass `kubeadm config validate`.
2. Write the following facts, one `key=value` per line (no spaces around `=`), to `/home/candidate/answers/q81.txt`:
   ```
   controller_manager_leader=<name of the node that currently holds the kube-controller-manager leader lease of this cluster>
   quorum_5=<quorum size of a 5-member etcd cluster>
   tolerated_failures_5=<member failures that a 5-member etcd cluster survives>
   min_members_survive_2=<smallest etcd cluster size that survives the loss of 2 members>
   ```

Constraints:
- Read the lease holder from the cluster; do not change anything in the cluster.
