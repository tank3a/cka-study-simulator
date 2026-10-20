# q62 해설: 기존 VPA 수정 (targetRef, Initial, controlledValues, 컨테이너 제외)

문서:
- https://kubernetes.io/docs/concepts/workloads/autoscaling/vertical-pod-autoscale/
- https://kubernetes.io/docs/concepts/workloads/autoscaling/

## 진단
```bash
kubectl config use-context k8s
kubectl -n vpa-b get vpa web-vpa -o yaml
```
`targetRef.name: web-frontend` 는 존재하지 않는 Deployment 이름이고 `updateMode: Auto` 는 실행 중 Pod 를 evict 한다.

## 풀이
```bash
kubectl -n vpa-b edit vpa web-vpa
```
```yaml
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  updatePolicy:
    updateMode: "Initial"
  resourcePolicy:
    containerPolicies:
    - containerName: web
      controlledValues: RequestsOnly
    - containerName: log-sidecar
      mode: "Off"
```
- `Initial`: Pod 생성 시에만 적용 (evict 안 함).
- `controlledValues: RequestsOnly`: limits 는 건드리지 않음 (기본은 `RequestsAndLimits`).
- 컨테이너 제외는 `mode: "Off"` (따옴표 필수).

## 검증
```bash
kubectl -n vpa-b get vpa web-vpa -o jsonpath='{.spec}' | jq .
```

## 흔한 실수
- `mode: Off` 를 따옴표 없이 입력 (boolean).
- `updateMode: Off` 로 바꿈 (문제는 "생성 시에만 적용" = `Initial`).
- VPA 를 삭제 후 재생성 (label 을 잃음).

## 충실도 메모
low: kind 에는 VPA 컨트롤러가 없다. CRD 스탠드인 위의 API 객체 편집만 채점한다.
