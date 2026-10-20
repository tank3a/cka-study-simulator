Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

Two applications in namespace `{{namespace}}` each use their own PVC on their own StorageClass:
`orders-db` (500Mi, used by Pod `orders`) and `archive` (500Mi, used by Pod `archiver`).

1. The PVC `orders-db` must grow to `2Gi`. Do not delete or recreate any Pod or PVC.
2. The PVC `archive` and the StorageClass it uses must stay unchanged. Archived data must never be resized.
3. Write one line `<storageclass-name> <allowVolumeExpansion value>` for the class used by `orders-db` into `/home/candidate/q51.txt`
   on the terminal host (example format: `my-class false`, using the value after your change).

Note: the volume plugin in this lab does not resize the underlying filesystem; the task is graded on the API objects.
