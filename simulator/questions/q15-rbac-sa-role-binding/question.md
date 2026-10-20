Context: `kubectl config use-context {{context}}`

The CI pipeline in namespace `{{namespace}}` runs as a ServiceAccount that does not exist yet.

1. Create a ServiceAccount `ci-deployer` in namespace `{{namespace}}`.
2. Create a Role `deploy-manager` in `{{namespace}}` that allows exactly:
   - `get`, `list`, `watch`, `create`, `update`, `patch` on `deployments` (apiGroup `apps`)
   - `get`, `list` on `pods`, and `get` on the `pods/log` subresource
3. Bind the Role to the ServiceAccount with a RoleBinding named `ci-deployer-binding`.
4. The existing Deployment `pipeline` in `{{namespace}}` must run with the new ServiceAccount. Do not recreate the Deployment.
5. Verify with `kubectl auth can-i` that `ci-deployer` is NOT allowed to `delete` deployments in `{{namespace}}`.
   Write only the answer (`yes` or `no`) to `/home/candidate/answers/q15-delete.txt`.

Constraints:
- No wildcards (`*`) in the Role.
- `ci-deployer` must have no access in namespace `rbac-prod`.
- Do not use a ClusterRole or ClusterRoleBinding.
