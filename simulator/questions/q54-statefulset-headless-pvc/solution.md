# q54 해설: StatefulSet + headless Service + volumeClaimTemplates

문서 (kubernetes.io 검색창에서 `StatefulSet` 검색, "Components" 예제 사용):
- https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/ (`Ctrl+F` `volumeClaimTemplates`)
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/ (PVC 개념)

## 핵심
- headless Service: `clusterIP: None`. StatefulSet `serviceName` 이 이 서비스 이름과 같아야 `<pod>.<svc>.<ns>.svc` DNS 가 생긴다.
- `volumeClaimTemplates` 는 Pod 마다 PVC `<template>-<sts>-<ordinal>` (여기서는 `data-kv-0`, `data-kv-1`) 를 만든다. `volumes:` 에 직접 쓰지 않는다.
- `kubectl create` 로 statefulset 은 만들 수 없다. 문서 예제를 복사해 수정.

## 풀이
```bash
kubectl config use-context k8s
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Service
metadata: {name: kv, namespace: sts-demo}
spec:
  clusterIP: None
  selector: {app: kv}
  ports:
  - {port: 80, name: web}
---
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: kv, namespace: sts-demo}
spec:
  serviceName: kv
  replicas: 2
  podManagementPolicy: Parallel
  selector:
    matchLabels: {app: kv}
  template:
    metadata:
      labels: {app: kv}
    spec:
      containers:
      - name: kv
        image: busybox:1.37
        command: ["sh", "-c", "echo $(hostname) > /data/id; sleep 3600"]
        volumeMounts:
        - {name: data, mountPath: /data}
  volumeClaimTemplates:
  - metadata: {name: data}
    spec:
      accessModes: [ReadWriteOnce]
      resources: {requests: {storage: 1Gi}}
EOF
```

## 검증
```bash
kubectl -n sts-demo get sts,pods,pvc
kubectl -n sts-demo exec dns-probe -- nslookup kv-1.kv.sts-demo.svc.cluster.local
```

## 흔한 실수
- Service 가 headless 가 아님 (`clusterIP: None` 누락) -> Pod 별 DNS 레코드가 없다.
- `serviceName` 오타.
- `volumeClaimTemplates` 에 `storageClassName` 을 임의 값으로 지정하면 Pending (기본 클래스를 쓰라고 했으므로 생략).
- Service selector 와 Pod label 불일치 (DNS 레코드는 Ready Pod 만).
