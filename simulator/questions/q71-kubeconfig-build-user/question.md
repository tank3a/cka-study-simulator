Context: `kubectl config use-context {{context}}`

The certificate and key of user `ravi` are in `/home/candidate/creds` (`ravi.crt`, `ravi.key`). `ravi` has read-only access in namespace `{{namespace}}`.

1. Create the new kubeconfig file `/home/candidate/kc/ravi.kubeconfig` (use `--kubeconfig` for every command, do not touch `~/.kube/config`) with:
   - a cluster named `kcfg-cluster` with the **same API server address and CA** as the cluster in your current kubeconfig; the CA must be embedded;
   - a user `ravi` with the certificate and key **embedded** in the file;
   - a context `ravi@kcfg` using that cluster and user and the default namespace `{{namespace}}`;
   - `ravi@kcfg` as the current context.
2. Write the names of all contexts of your **default** kubeconfig, sorted, one per line, to `/home/candidate/answers/q71-contexts.txt`.

Constraints:
- The new file must work without any other file (no file paths inside).
