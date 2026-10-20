# q61 해설: VPA recommendation-only (updateMode Off) + resourcePolicy

문서:
- https://kubernetes.io/docs/concepts/workloads/autoscaling/vertical-pod-autoscale/
- https://kubernetes.io/docs/concepts/workloads/autoscaling/ (HPA 와 VPA 개요 비교)

## 핵심
- VPA 는 core 리소스가 아니라 CRD(`autoscaling.k8s.io/v1`, kind `VerticalPodAutoscaler`) 이다. 실제 시험에서는 클러스터에 설치되어 있다고 가정하고 문서 YAML 만 쓴다.
- `updatePolicy.updateMode`: `Off`(추천만 계산), `Initial`(생성 시에만 적용), `Recreate`/`Auto`(실행 중 Pod 를 evict 하며 적용).
- 컨테이너별 `resourcePolicy.containerPolicies[].minAllowed/maxAllowed/controlledResources`.

## 풀이
```bash
kubectl config use-context k8s
kubectl apply -f - <<'EOF'
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: sizing-vpa
  namespace: vpa-a
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: sizing-target
  updatePolicy:
    updateMode: "Off"
  resourcePolicy:
    containerPolicies:
    - containerName: app
      minAllowed: {cpu: 50m, memory: 64Mi}
      maxAllowed: {cpu: 500m, memory: 512Mi}
      controlledResources: ["cpu", "memory"]
EOF
```
`"Off"` 는 반드시 따옴표 (YAML 1.1 에서 Off 는 boolean false).

## 검증
```bash
kubectl -n vpa-a get vpa sizing-vpa -o yaml
kubectl -n vpa-a describe vpa sizing-vpa      # 실제 VPA 에서는 Recommendation 섹션
```

## 흔한 실수
- `updateMode: Off` 를 따옴표 없이 써서 boolean 으로 파싱되어 거부/변형.
- `targetRef` 에 apiVersion/kind 누락.
- HPA 가 같은 메트릭(cpu/memory)을 쓰는 Deployment 에 VPA 를 `Auto` 로 겹쳐 쓰는 것은 충돌.

## 충실도 메모
low: kind 에는 VPA recommender/updater/admission 이 없고 metrics-server 만 있다. API 객체 모양만 채점한다.
