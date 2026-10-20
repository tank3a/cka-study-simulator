Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The application Pod `data-writer` in namespace `{{namespace}}` stores its data on the PVC `data-pvc`
(currently `1Gi`, StorageClass `expandable-sc`). The application needs `3Gi`.

Increase the storage request of `data-pvc` to `3Gi`.
Do not delete or recreate the Pod, the PVC or the StorageClass. Do not use any other StorageClass.

Note: the volume plugin in this lab does not resize the underlying filesystem; the task is graded on the API objects.
