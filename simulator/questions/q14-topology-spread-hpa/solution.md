# q14 해설: topologySpreadConstraints + 롤링 업데이트 전략 + HPA

문서:
- https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ (`Ctrl+F` `topologySpreadConstraints` 의 첫 YAML 예제)
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

## 1~2) Deployment 수정
```bash
kubectl config use-context k8s
kubectl get nodes -L zone
kubectl -n spread-demo edit deploy api
```
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  template:
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app: api
        matchLabelKeys:          # rolling update 중 old ReplicaSet Pod 를 skew 계산에서 제외 (1.27+ beta, 기본 활성)
        - pod-template-hash
      containers:
      - name: api
        image: nginx:1.27
        resources:
          requests:
            cpu: 50m
```
- `topologySpreadConstraints` 는 pod template 의 `spec` 아래이며 `containers` 와 같은 레벨.
- `labelSelector` 는 template 의 pod label (`app: api`) 과 일치해야 한다 (틀리면 spread 가 의미 없음).
- `topologyKey: zone` 인 이유: 노드 label `zone` 이 없는 control-plane 은 도메인에서 제외된다. `kubernetes.io/hostname` 을 쓰면 taint 된 control-plane(0 Pod)도 도메인으로 세어져 4 Pod 배치가 막힐 수 있다.
- 한 번의 `edit` 로 전략/spread/request 를 모두 수정하면 롤아웃이 한 번만 일어난다.
- **주의 (검증됨)**: `matchLabelKeys` 없이 적용하면 롤아웃 중 아직 Terminating 인 old Pod 까지 `app=api` 로 세어져서
  새 Pod 가 한 zone 에 3개, 다른 zone 에 1개로 고정될 수 있다 (spread 는 스케줄링 시점에만 평가된다).
  `matchLabelKeys: [pod-template-hash]` 를 넣으면 새 ReplicaSet 의 Pod 끼리만 비교하므로 2/2 가 된다.
  이미 3/1 로 배치됐다면 해당 zone 의 Pod 하나를 `kubectl delete pod` 로 지워 재스케줄시킨다.

## 3) HPA
```bash
kubectl -n spread-demo autoscale deploy api --name=api-hpa --min=4 --max=6 --cpu=80%
kubectl -n spread-demo get hpa
```
(이 문제에서는 behavior 가 없으므로 imperative 명령으로 충분하다. request 를 먼저 넣어야 TARGETS 가 `<unknown>` 이 되지 않는다.)

## 검증
```bash
kubectl -n spread-demo rollout status deploy/api
kubectl -n spread-demo get pods -o wide        # worker 마다 2개
kubectl -n spread-demo get hpa api-hpa
```

## 흔한 실수
- `labelSelector` 오타 / 누락.
- `whenUnsatisfiable: ScheduleAnyway` 로 쓴 경우 (요구는 DoNotSchedule).
- `maxSurge`, `maxUnavailable` 을 `spec.rollingUpdate` 에 두는 오류 (정확한 경로는 `spec.strategy.rollingUpdate`).
- HPA 는 만들었지만 CPU request 누락.
