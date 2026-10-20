Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

Several PersistentVolumes already exist in the cluster.

1. The PV `legacy-pv` is bound to the claim `legacy-pvc` in namespace `{{namespace}}`. Its data must survive
   if the claim is ever deleted. Change the reclaim policy of `legacy-pv` to `Retain`.
   Do NOT delete or recreate the PV or the PVC.

2. In namespace `{{namespace}}` create a PersistentVolumeClaim `reports-pvc` that:
   - requests `2Gi` with access mode `ReadOnlyMany`
   - selects a PV with the label `tier=reports`
   - does not use any StorageClass (no dynamic provisioning)
   Do not modify any existing PV. The claim must become Bound.

3. Create a Pod `reports-reader` in `{{namespace}}` (image `busybox:1.37`, command `sleep 3600`) that mounts
   `reports-pvc` at `/reports` in read-only mode (set it on the volume mount of the container).
