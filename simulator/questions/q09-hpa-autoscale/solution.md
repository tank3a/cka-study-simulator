# q09 해설: HPA (함정: resources.requests 없음)

문서:
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/
- https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/ (`Ctrl+F` `stabilizationWindowSeconds`)

## 함정
HPA 의 `Utilization` 타입은 Pod 의 **CPU request 대비 사용률** 이다. Deployment 에 `resources.requests.cpu` 가 없으면
HPA 의 TARGETS 가 `<unknown>/60%` 로 남는다 (events: `failed to get cpu utilization: missing request for cpu`).
따라서 Deployment 에 request 를 먼저 넣는다.

## 풀이
```bash
kubectl config use-context k8s
kubectl -n hpa-demo set resources deploy/web --requests=cpu=100m,memory=64Mi --limits=cpu=200m,memory=128Mi
```
뼈대 생성(autoscale 명령은 behavior 를 지원하지 않으므로 YAML 로 마무리):
```bash
kubectl -n hpa-demo autoscale deploy web --name=web-hpa --min=2 --max=8 --cpu=60% \
  --dry-run=client -o yaml > hpa.yaml
vim hpa.yaml
```
`spec` 에 behavior 추가 (apiVersion 은 `autoscaling/v2` 로 되어 있는지 확인; v1 이면 v2 로 바꾸고 metrics 형태 사용):
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
  namespace: hpa-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 8
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 30
```
`kubectl apply -f hpa.yaml`

## 검증
```bash
kubectl -n hpa-demo get hpa web-hpa -w        # TARGETS 가 숫자%/60% 로 바뀌는지 (최대 1~2분)
kubectl -n hpa-demo get deploy web            # min 2 -> 2 replicas
kubectl top pods -n hpa-demo
```

## 흔한 실수
- request 를 넣지 않아 `<unknown>`.
- `autoscaling/v1` 로 작성해서 behavior 필드를 못 씀.
- `behavior` 를 `spec.metrics` 안에 넣음 (spec 바로 아래가 맞다).
- Deployment 의 `replicas` 를 HPA 와 별도로 고정하려 함 (HPA 가 덮어씀).
