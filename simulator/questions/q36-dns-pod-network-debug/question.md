You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`   Node for part 2: `{{host}}`

**Part 1: DNS.** The Pod `broken-client` in namespace `net-debug` cannot resolve any Service name, although the Service
`backend` (port 80) is healthy and the cluster DNS works for other Pods (for example the Pod `healthy-client`).
Find the cause and fix it so that `wget -qO- http://backend` works inside `broken-client`.
The Pod must keep its name, image and command and must use the normal cluster DNS (do not hard-code DNS server addresses).
Fixing it may require recreating the Pod.

**Part 2: Pod network facts.** Write the following three values (one value, a single line, no extra text) into files on this terminal:

- `/home/candidate/podcidr-node1.txt`: the Pod CIDR assigned to the node `k8s-worker`.
- `/home/candidate/cni-conf.txt`: the file name (not the path) of the CNI configuration file in `/etc/cni/net.d/` on the node `k8s-worker`
  (reach it with `ssh {{host}}`; the directory is root-only, use `sudo`).
- `/home/candidate/dns-ip.txt`: the ClusterIP of the Service that exposes the cluster DNS (CoreDNS) in `kube-system`.
