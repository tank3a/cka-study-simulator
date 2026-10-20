You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

A Deployment `echo` and its ClusterIP Service `echo` (port name `http`, port 80) run in the namespace.

Create the file `/home/candidate/kube-proxy.txt` with exactly these three lines:

    mode=<the proxy mode kube-proxy is configured with; write iptables if the field is empty>
    cluster-cidr=<the clusterCIDR value from the kube-proxy configuration>
    chain=<the name of the KUBE-SVC-... iptables chain that kube-proxy created for the Service echo (port 80)>

Hints: kube-proxy runs as a DaemonSet in `kube-system` and its configuration is stored in a ConfigMap. The nat table of a node can be read with `ssh k8s-node1` and `sudo iptables-save -t nat`.
Do not change anything in `kube-system`.
