Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (needed for one of the answers)

Your team plans to turn this cluster into a highly available one. Collect facts about the current control plane and write them to `/home/candidate/answers/q21.txt`, exactly in this format (one `key=value` per line, no spaces around `=`):

```
topology=<stacked|external>
scheduler_leader=<name of the control plane node that currently holds the kube-scheduler leader lease>
control_plane_endpoint=<controlPlaneEndpoint from the kubeadm ClusterConfiguration>
etcd_members=<number of members in the etcd cluster>
min_cp_nodes_for_ha=<smallest number of control plane nodes with stacked etcd that survives the loss of one node>
```

Constraints:
- Read the values from the running cluster; do not guess.
- Do not change anything in the cluster.
