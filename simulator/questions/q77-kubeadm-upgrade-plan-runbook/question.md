Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

Next week the cluster will be upgraded to the next minor version. Prepare the maintenance (do **not** upgrade anything now):

1. On the control plane node, save the output of the kubeadm command that shows which versions the cluster can be upgraded to to `/opt/cka/upgrade-plan.txt`.
2. Show what draining the worker node `ek8s-worker` would do, **without** changing the node: run the drain with a server-side dry run (ignore DaemonSets, delete emptyDir data) and save the output to `/opt/cka/drain-dryrun.txt`.
3. Write the ordered list of commands you will run on the **worker node** to upgrade it (one command per line, in `/opt/cka/upgrade-runbook.txt`). It must contain, in this order: drain of the node, installation of the new `kubeadm` package, the kubeadm command that upgrades a worker node, installation of the new `kubelet` package, the kubelet restart, and the uncordon.

Constraints:
- `ek8s-worker` must stay schedulable.
- Do not install or upgrade any package now.
