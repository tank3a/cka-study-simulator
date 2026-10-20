Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

A new web application needs persistent storage. The namespace `{{namespace}}` already exists.

1. Create a PersistentVolume named `pv-data` with these properties:
   - capacity `1Gi`, access mode `ReadWriteOnce`
   - `storageClassName: manual`
   - reclaim policy `Retain`
   - backed by hostPath `/mnt/data-app` (the directory already exists on the worker nodes)

2. Create a PersistentVolumeClaim named `pvc-data` in namespace `{{namespace}}`:
   - requests `500Mi`, access mode `ReadWriteOnce`, `storageClassName: manual`
   - it must bind to `pv-data`

3. Create a Deployment named `data-app` in namespace `{{namespace}}`:
   - image `nginx:1.27`, 1 replica
   - mount the PVC `pvc-data` at `/usr/share/nginx/html`

Do not use dynamic provisioning and do not modify the default StorageClass.
All objects must end up Bound / Running.
