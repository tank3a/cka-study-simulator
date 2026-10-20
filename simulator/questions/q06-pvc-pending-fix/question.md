Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The Deployment `ledger-app` in namespace `{{namespace}}` never becomes Available. Its Pod is Pending because the
PersistentVolumeClaim `ledger-pvc` is not bound.

The PersistentVolume `pv-ledger` was provisioned by the storage team for this application and is Available.

Fix the problem so that `ledger-pvc` binds to `pv-ledger` and the Deployment becomes Available.

Constraints:
- Do NOT modify or delete the PersistentVolume `pv-ledger`.
- Do NOT modify the Deployment `ledger-app` (it must keep referencing a claim named `ledger-pvc`).
- The claim must request `3Gi`.
