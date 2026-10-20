# q53 해설: nodeSelector + hostPath(readOnly) + RollingUpdate DaemonSet

문서 (kubernetes.io 검색창에서 `DaemonSet` 으로 페이지를 찾아 YAML 예제를 복사):
- https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/ (`Ctrl+F` `kind: DaemonSet` 예제)
- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ (nodeSelector)

## 풀이
`kubectl create` 에는 daemonset 생성 명령이 없으므로 Deployment YAML 을 dry-run 으로 만들어 kind 를 바꾸거나 문서 예제를 쓴다.
```bash
kubectl config use-context k8s
kubectl -n ds-demo create deploy log-agent --image=busybox:1.37 --dry-run=client -o yaml -- sleep 3600 > ds.yaml
vim ds.yaml    # kind: DaemonSet, replicas/strategy 삭제, 아래 내용 반영
```
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-agent
  namespace: ds-demo
spec:
  selector:
    matchLabels: {app: log-agent}
  updateStrategy:
    type: RollingUpdate
    rollingUpdate: {maxUnavailable: 1}
  template:
    metadata:
      labels: {app: log-agent}
    spec:
      nodeSelector: {disk: ssd}
      containers:
      - name: agent
        image: busybox:1.37
        command: ["sleep", "3600"]
        volumeMounts:
        - {name: host-logs, mountPath: /host-logs, readOnly: true}
      volumes:
      - name: host-logs
        hostPath: {path: /var/log}
```
```bash
kubectl apply -f ds.yaml
kubectl label node k8s-worker2 disk=ssd      # DaemonSet 이 자동으로 새 노드에 Pod 생성
```

## 검증
```bash
kubectl -n ds-demo get ds log-agent
kubectl -n ds-demo get pods -o wide
```

## 흔한 실수
- DaemonSet 에는 `replicas` 가 없다 (dry-run YAML 에서 지우지 않으면 에러).
- `readOnly: true` 를 volume(hostPath) 이 아니라 volumeMount 에 넣어야 한다.
- 노드 라벨 대신 DaemonSet 을 다시 수정함 (라벨 추가만으로 스케줄되는 것이 DaemonSet 의 핵심).
- control-plane 은 taint 때문에 toleration 을 넣지 않으면 자연히 제외된다 (toleration 추가 금지).
