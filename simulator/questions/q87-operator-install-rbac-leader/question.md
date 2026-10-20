Context: `kubectl config use-context {{context}}`

The vendor bundle `/home/candidate/operator/bundle.yaml` contains the namespace `{{namespace}}`, the CRD `SyncJob` (group `sync.cka.example.com`), the ServiceAccount `sync-operator` and the Deployment `sync-operator` (shipped with 0 replicas). The bundle contains **no RBAC**.

1. Install the bundle.
2. Give the ServiceAccount `sync-operator` the permissions an operator for this CRD needs, using least privilege and the names below:
   - ClusterRole `sync-operator` + ClusterRoleBinding `sync-operator`: `get`, `list`, `watch`, `update`, `patch` on `syncjobs`, on `syncjobs/status` and on `syncjobs/finalizers` of group `sync.cka.example.com` (all namespaces), and `create`, `patch` on `events`.
   - Role `leader-election` + RoleBinding `leader-election` in namespace `{{namespace}}`: `get`, `list`, `watch`, `create`, `update`, `patch` on `leases` (group `coordination.k8s.io`).
3. Start the operator: scale the Deployment `sync-operator` to 1 replica and wait until it is available.
4. Create a SyncJob `nightly` in namespace `{{namespace}}` with `spec.source: s3://src` and `spec.dest: s3://dst`.

Constraints:
- No wildcards and no `cluster-admin`.
- The operator must not be able to delete SyncJobs or create Deployments.
