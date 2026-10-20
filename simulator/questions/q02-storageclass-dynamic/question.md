Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The cluster uses the `rancher.io/local-path` provisioner (the existing StorageClass `standard` is backed by it).

1. Create a new StorageClass named `fast-local`:
   - provisioner `rancher.io/local-path`
   - `volumeBindingMode: WaitForFirstConsumer`
   - `reclaimPolicy: Retain`
   - volume expansion allowed
   - it must NOT be the default StorageClass

2. In namespace `{{namespace}}` create a PersistentVolumeClaim `web-pvc` that requests `1Gi` with access mode `ReadWriteOnce` from StorageClass `fast-local`.

3. Create a Deployment `web` in `{{namespace}}` (image `nginx:1.27`, 1 replica) that mounts `web-pvc` at `/data`.

The PVC must be Bound and the Pod Running. Do not modify or delete the existing StorageClass `standard`.
