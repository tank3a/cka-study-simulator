Context: `kubectl config use-context {{context}}`

Namespaces `cr-a` and `cr-b` exist. The ServiceAccount `deployer` lives in `cr-a`.

1. Create the ClusterRole `ns-lister` that allows `get`, `list` and `watch` on `namespaces`.
   Bind it cluster-wide to the **group** `ops-audit` with the ClusterRoleBinding `ns-lister`.
2. Create the ClusterRole `cm-editor` that allows `get`, `list`, `watch`, `update` and `patch` on `configmaps`.
   Give it to the ServiceAccount `deployer` **only inside namespace `cr-a`** with the RoleBinding `cm-editor`
   (the RoleBinding must reference the ClusterRole).
3. Create the ClusterRole `metrics-reader` that allows `get` on the non-resource URL `/metrics`.
   Bind it cluster-wide to the **user** `monitor` with the ClusterRoleBinding `metrics-reader`.

Constraints:
- No wildcard (`*`) verbs or resources.
- `deployer` must not be able to edit ConfigMaps in `cr-b`.
