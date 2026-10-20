Context: `kubectl config use-context {{context}}`

A vendor CSI driver named `hostpath.csi.cka.example.com` will be rolled out next week. Prepare the cluster objects (no driver Pods exist yet).

1. Create the CSIDriver `hostpath.csi.cka.example.com` with: no attach step (`attachRequired: false`), Pod info passed on mount (`podInfoOnMount: true`) and the volume lifecycle modes `Persistent` and `Ephemeral`.
2. Create the StorageClass `csi-fast` for that driver: reclaim policy `Retain`, volume binding mode `WaitForFirstConsumer`, volume expansion allowed, parameter `type=fast`, mount option `noatime`. It must **not** be the default class.
3. Create a PersistentVolumeClaim `data` (1Gi, `ReadWriteOnce`, StorageClass `csi-fast`) in namespace `{{namespace}}`.
4. Write the following facts, one `key=value` per line, to `/home/candidate/answers/q90.txt`:
   ```
   default_storageclass_provisioner=<provisioner of the default StorageClass>
   default_provisioner_is_csidriver=<yes|no: is that provisioner registered as a CSIDriver object?>
   csinode_driver_count_k8s_worker=<number of drivers listed in the CSINode object of node k8s-worker>
   pvc_data_phase=<current phase of PVC data>
   ```
