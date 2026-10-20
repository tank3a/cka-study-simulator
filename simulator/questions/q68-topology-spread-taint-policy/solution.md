# q68 해설: topologySpreadConstraints (labelSelector, DoNotSchedule, nodeTaintsPolicy)

문서:
- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ (topology spread 설명 및 `Ctrl+F` `topologySpreadConstraints`)
- https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

## 진단
```bash
kubectl config use-context k8s
kubectl -n spread2 get deploy spread-app -o yaml | grep -A8 topologySpread
```
- `labelSelector.matchLabels.app: spreadapp` 는 Pod 라벨(`spread-app`)과 달라 아무것도 세지 못한다.
- `maxSkew: 3`, `ScheduleAnyway` 는 균등 분산을 강제하지 않는다.

## 풀이
```bash
kubectl -n spread2 edit deploy spread-app
```
```yaml
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        nodeTaintsPolicy: Honor
        labelSelector:
          matchLabels: {app: spread-app}
```
함정: `nodeTaintsPolicy` 기본값(Ignore)에서는 Pod 가 toleration 이 없는 control-plane 노드도 "0개 Pod 의 도메인" 으로 skew 계산에 포함된다.
그러면 worker 한 대당 1개 이상은 maxSkew 1 을 위반하여 3번째 Pod 부터 Pending 이 된다. `nodeTaintsPolicy: Honor` 는 Pod 가 견딜 수 없는 taint 노드를 도메인에서 제외한다.
(Pending 이벤트: `didn't match pod topology spread constraints`.)

## 검증
```bash
kubectl -n spread2 rollout status deploy/spread-app
kubectl -n spread2 get pods -o wide
kubectl -n spread2 describe pod <pending-pod> | tail     # Pending 이면 이벤트 확인
```

## 흔한 실수
- `labelSelector` 오타 (자신의 Pod 를 세지 못함).
- `ScheduleAnyway` 유지.
- Pending 을 본 뒤 control-plane taint 를 제거하거나 toleration 을 추가 (금지, 그러면 Pod 가 control-plane 에도 배치된다).
- `maxSkew: 1` 로만 바꾸고 Pending 원인(taint 노드 도메인)을 확인하지 않음.
