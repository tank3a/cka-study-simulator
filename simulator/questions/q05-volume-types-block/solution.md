# q05 해설: 볼륨 종류(emptyDir/hostPath/configMap)와 volumeMode: Block

## Part A: 멀티 컨테이너 Pod
문서: https://kubernetes.io/docs/concepts/storage/volumes/ (`Ctrl+F` 로 `emptyDir`, `hostPath`, `configMap` 각각 이동해서 예제 복사)
```bash
kubectl config use-context k8s
kubectl -n vol-demo run multi-vol --image=busybox:1.37 --dry-run=client -o yaml -- sleep 3600 > pod.yaml
vim pod.yaml
```
최종 형태:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-vol
  namespace: vol-demo
spec:
  containers:
  - name: writer
    image: busybox:1.37
    command: ["sh","-c","while true; do date >> /shared/out.log; sleep 5; done"]
    volumeMounts:
    - {name: shared, mountPath: /shared}
    - {name: hostlogs, mountPath: /hostlogs}
  - name: reader
    image: busybox:1.37
    command: ["tail","-F","/shared/out.log"]
    volumeMounts:
    - {name: shared, mountPath: /shared}
    - {name: conf, mountPath: /etc/conf, readOnly: true}
  volumes:
  - name: shared
    emptyDir:
      medium: Memory
      sizeLimit: 64Mi
  - name: hostlogs
    hostPath:
      path: /var/log/multi-vol
      type: DirectoryOrCreate
  - name: conf
    configMap:
      name: app-conf
```
이것이 "classic sidecar" 패턴(두 컨테이너가 emptyDir 공유)이다. `kubectl run` 이 만든 `command: [sleep, 3600]` 은 컨테이너별로 교체해야 한다.

## Part B: Block 모드 PV/PVC
문서: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#raw-block-volume-support (`Ctrl+F` `volumeMode`)
PV 와 PVC 의 `volumeMode` 가 같아야 바인딩된다 (둘 다 Block). 기본값은 Filesystem.
```yaml
apiVersion: v1
kind: PersistentVolume
metadata: {name: raw-pv}
spec:
  capacity: {storage: 2Gi}
  accessModes: [ReadWriteOnce]
  volumeMode: Block
  storageClassName: raw
  persistentVolumeReclaimPolicy: Retain
  hostPath: {path: /dev/raw-lab}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: raw-pvc, namespace: vol-demo}
spec:
  accessModes: [ReadWriteOnce]
  volumeMode: Block
  storageClassName: raw
  resources: {requests: {storage: 1Gi}}
```
참고: Pod 에서 Block PVC 를 쓰려면 `volumeMounts` 대신 container 의 `volumeDevices: [{name, devicePath}]` 를 쓴다 (이 문제에서는 불필요).

## 검증
```bash
kubectl -n vol-demo get pod multi-vol
kubectl -n vol-demo logs multi-vol -c reader --tail=3
kubectl get pv raw-pv; kubectl -n vol-demo get pvc raw-pvc
```

## 흔한 실수
- `emptyDir.sizeLimit` 을 `emptyDir` 와 같은 레벨이 아니라 volume 레벨에 씀.
- volumeMounts 의 `name` 과 volumes 의 `name` 불일치.
- PVC 에 `volumeMode: Block` 을 안 넣어 PV 와 모드 불일치 -> Pending.
- configMap volume 을 `readOnly` 로 쓰는 위치는 volumeMount (volume 쪽이 아님).
