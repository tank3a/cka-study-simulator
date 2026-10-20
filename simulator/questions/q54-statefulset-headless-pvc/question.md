Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

In namespace `{{namespace}}` create:

1. A headless Service `kv` (selector `app=kv`, port `80`).
2. A StatefulSet `kv` with `2` replicas that uses the Service `kv` as its governing service, Pod label `app=kv`,
   image `busybox:1.37`, container name `kv`, command `sh -c 'echo $(hostname) > /data/id; sleep 3600'`.
   Each replica must get its **own** PersistentVolumeClaim from a `volumeClaimTemplates` entry named `data`
   (`ReadWriteOnce`, `1Gi`, default StorageClass) mounted at `/data`.
   Pods must start in parallel (`podManagementPolicy: Parallel`).

Both Pods must become Ready, and the Pod `kv-1` must be reachable under its stable DNS name `kv-1.kv.{{namespace}}.svc.cluster.local`.
