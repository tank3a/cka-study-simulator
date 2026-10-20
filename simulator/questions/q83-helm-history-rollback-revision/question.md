Context: `kubectl config use-context {{context}}`

Release `ledger` in namespace `{{namespace}}` was upgraded several times and now has Pods that cannot pull their image.

1. Use the release history to find the **first revision** that deployed image tag `1.27-alpine`. Write only the revision number to `/home/candidate/answers/q83-revision.txt`.
2. Roll the release back to exactly that revision.
3. Save the user-supplied values (not the computed defaults) of the release as they are **after** the rollback to `/home/candidate/answers/q83-values.yaml`.
4. The Pods of the release must be Running.

Constraints:
- Do not uninstall and re-install the release.
- Do not use `helm upgrade` for the repair.
