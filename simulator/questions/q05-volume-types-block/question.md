Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

Part A. Create a Pod `multi-vol` in namespace `{{namespace}}` with two containers and three volumes:

- container `writer` (image `busybox:1.37`) runs `sh -c 'while true; do date >> /shared/out.log; sleep 5; done'`
- container `reader` (image `busybox:1.37`) runs `tail -F /shared/out.log`
- volume `shared`: an `emptyDir` stored in memory (`medium: Memory`) with `sizeLimit: 64Mi`; mounted at `/shared` in both containers
- volume `hostlogs`: a `hostPath` of `/var/log/multi-vol` with type `DirectoryOrCreate`; mounted at `/hostlogs` in `writer`
- volume `conf`: the existing ConfigMap `app-conf`; mounted at `/etc/conf` in `reader`, read-only

The Pod must reach Running with both containers ready.

Part B. Create a raw block volume claim:

- PersistentVolume `raw-pv`: `2Gi`, `ReadWriteOnce`, `volumeMode: Block`, `storageClassName: raw`,
  `persistentVolumeReclaimPolicy: Retain`, hostPath `/dev/raw-lab` (type is not important)
- PersistentVolumeClaim `raw-pvc` in `{{namespace}}`: `1Gi`, `ReadWriteOnce`, `volumeMode: Block`, `storageClassName: raw`

`raw-pvc` must be Bound to `raw-pv`. (You do not need to start a Pod that uses it.)
