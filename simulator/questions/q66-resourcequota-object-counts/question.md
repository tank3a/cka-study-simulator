Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

Namespace `{{namespace}}` already contains one Deployment `existing` and one PVC `pvc-a` (`1Gi`).
Limit what this namespace can create:

1. Create a ResourceQuota `object-caps` in namespace `{{namespace}}` that allows at most:
   - `2` Deployments (`count/deployments.apps`)
   - `2` PersistentVolumeClaims
   - `3Gi` of total requested storage (`requests.storage`)
   - `0` Services of type NodePort
2. The directory `/home/candidate/quota-tests/` contains five manifests. Apply the whole directory to namespace `{{namespace}}`
   (all five must be attempted even though some will fail) and save everything `kubectl` prints on **stderr** into `/home/candidate/quota-errors.txt`.
   Do not edit the manifests.
