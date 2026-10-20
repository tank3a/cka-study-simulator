# q90 풀이

```bash
kubectl config use-context k8s
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: hostpath.csi.cka.example.com
spec:
  attachRequired: false
  podInfoOnMount: true
  volumeLifecycleModes: [Persistent, Ephemeral]
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-fast
provisioner: hostpath.csi.cka.example.com
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
parameters:
  type: fast
mountOptions: [noatime]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: data, namespace: csi-lab}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: csi-fast
  resources: {requests: {storage: 1Gi}}
EOF

# 사실 조사
kubectl get sc                                        # (default) 표시된 클래스의 PROVISIONER
kubectl get csidrivers                                # 기본 provisioner(rancher.io/local-path)는 CSIDriver가 아님 -> no
kubectl get csinode k8s-worker -o jsonpath='{.spec.drivers[*].name}' | wc -w     # 0
kubectl -n csi-lab get pvc data -o jsonpath='{.status.phase}'                      # Pending

cat > ~/answers/q90.txt <<EOF
default_storageclass_provisioner=rancher.io/local-path
default_provisioner_is_csidriver=no
csinode_driver_count_k8s_worker=0
pvc_data_phase=Pending
EOF
```

핵심: CSIDriver는 드라이버의 동작 방식(attach 필요 여부, 마운트 시 Pod 정보 전달, 수명주기 모드)을 선언하는 클러스터 범위 객체이고, 노드별 CSINode가 실제 등록된 드라이버를 보여준다. 드라이버 Pod가 없고 `WaitForFirstConsumer`이므로 PVC는 Pending이 정상이다. kind의 기본 StorageClass는 CSI가 아닌 local-path provisioner이다.

문서: https://kubernetes.io/docs/concepts/storage/volumes/#csi
      https://kubernetes.io/docs/concepts/storage/storage-classes/
