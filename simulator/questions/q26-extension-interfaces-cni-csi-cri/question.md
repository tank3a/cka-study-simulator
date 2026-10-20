Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (needed for some answers; use `sudo -i`)

Collect the following facts about worker node `k8s-worker` and the cluster and write them to `/home/candidate/answers/q26.txt` in the exact format `key=value`, one per line:

```
cri_socket=<container runtime endpoint (CRI socket) the kubelet on k8s-worker uses, e.g. from its kubelet config or crictl config>
runtime_name=<name of the container runtime reported by crictl on k8s-worker>
cni_config_file=<file name (not the path) of the CNI configuration in /etc/cni/net.d on k8s-worker>
cni_bin_dir=<directory where CNI plugin binaries are installed on k8s-worker>
pod_cidr=<podCIDR assigned to node k8s-worker>
default_storageclass=<name of the default StorageClass>
csi_provisioner=<provisioner of the default StorageClass>
```

Then use the CRI extension point:

- Create a RuntimeClass `standard-runc` that uses the handler `runc`.
- Create a Pod `rc-pod` in namespace `{{namespace}}` (image `busybox:1.37`, command `sleep 3600`) that runs with this RuntimeClass.

Constraints:
- Do not change the node configuration; only read it.
