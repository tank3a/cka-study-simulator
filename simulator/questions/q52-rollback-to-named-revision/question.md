Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The Deployment `shop` in namespace `{{namespace}}` has been updated several times and the latest release is broken
(its new Pods never become Ready). Every revision carries a change-cause annotation.

1. Before changing anything, save the output of the Deployment's rollout history to `/home/candidate/history-before.txt` on the terminal host.
2. Roll the Deployment back to **the revision whose change-cause is `v2-stable`**. It is not the immediately previous revision.
3. After the rollback, set the change-cause annotation of the Deployment to `rollback to v2-stable`.
4. The Deployment must finish its rollout with all replicas available.
