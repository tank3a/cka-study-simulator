# q13 해설: nodeAffinity / podAntiAffinity / DaemonSet toleration / PriorityClass(preemptionPolicy: Never)

문서:
- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ (`Ctrl+F` `requiredDuringSchedulingIgnoredDuringExecution`, 그 아래 Node affinity / inter-pod affinity 예제)
- https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
- https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/ (`Ctrl+F` `preemptionPolicy`)

## 1) web-tier 의 affinity
```bash
kubectl config use-context k8s
kubectl get nodes --show-labels | grep -E 'tier|zone'
kubectl -n affinity-demo edit deploy web-tier
```
`spec.template.spec` 아래 (containers 와 같은 레벨) 에 추가:
```yaml
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: tier
                operator: In
                values: ["app"]
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 80
            preference:
              matchExpressions:
              - key: zone
                operator: In
                values: ["a"]
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                app: web-tier
            topologyKey: kubernetes.io/hostname
```
문서의 두 예제(nodeAffinity 예제 + "Inter-pod affinity and anti-affinity" 예제)를 복사해 붙인 후 값만 바꾼다.
들여쓰기 규칙: required 는 `nodeSelectorTerms` 리스트, preferred 는 `weight`+`preference` 리스트. 둘이 다르다.
podAntiAffinity 의 required 항목은 `labelSelector` + `topologyKey` (preferred 만 weight 가 있는 `podAffinityTerm` 래퍼를 쓴다).

## 2) DaemonSet 이 control-plane 에서도 실행
control-plane 의 taint 는 `node-role.kubernetes.io/control-plane:NoSchedule`.
```bash
kubectl -n affinity-demo edit ds node-agent
```
```yaml
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
```
(모든 taint 를 허용하려면 `- operator: Exists` 한 줄만 써도 되지만, 요구사항은 "control-plane 포함" 이므로 명시적 toleration 이 안전.)

## 3) PriorityClass
```bash
kubectl create priorityclass batch-low --value=100 --preemption-policy=Never --description="batch, no preemption"
kubectl -n affinity-demo patch deploy report-gen -p '{"spec":{"template":{"spec":{"priorityClassName":"batch-low"}}}}'
```
`--preemption-policy` 플래그가 없는 kubectl 버전이면 YAML 로: 
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata: {name: batch-low}
value: 100
preemptionPolicy: Never
globalDefault: false
```

## 검증
```bash
kubectl -n affinity-demo get pods -o wide
kubectl -n affinity-demo get ds node-agent        # DESIRED=3 READY=3
kubectl get pc batch-low -o jsonpath='{.preemptionPolicy}{"\n"}'
```

## 흔한 실수
- required/preferred 의 YAML 구조를 혼동 (preferred 는 `weight`/`preference`).
- podAntiAffinity 의 `topologyKey` 누락 (필수 필드).
- 필수 anti-affinity + 노드 수 부족이면 Pod 가 Pending (이 문제는 worker 2개 / replica 2개이므로 정확히 맞음).
- DaemonSet 에 toleration 을 넣지 않거나 `effect` 를 `NoExecute` 로 오기입.
- affinity 를 pod template 이 아닌 Deployment spec 에 넣음.
