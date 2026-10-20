Context: `kubectl config use-context {{context}}`

The ServiceAccount `reporter` in namespace `{{namespace}}` is used by a reporting tool. A security review found it has far too many permissions.

1. Find every ClusterRoleBinding whose subjects include the ServiceAccount `reporter` of namespace `{{namespace}}`.
   Write their names, one per line and sorted alphabetically, to `/home/candidate/answers/q16-bindings.txt`.
2. Remove the excessive access: delete those ClusterRoleBindings.
3. Grant the minimum the tool needs instead:
   - In namespace `{{namespace}}` only: `get`, `list`, `watch` on `pods` and `services`.
     Use a Role `reporter-read` and a RoleBinding `reporter-read`.
   - Cluster-wide: `get`, `list` on `nodes`.
     Use a ClusterRole `reporter-nodes` and a ClusterRoleBinding `reporter-nodes`.

Constraints:
- A ServiceAccount also called `reporter` exists in namespace `rbac-other`. Its bindings belong to another team: do not modify or delete them.
- The ServiceAccount `reporter` must not be able to read Secrets or delete Pods anywhere.
