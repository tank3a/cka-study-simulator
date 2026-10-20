# q63 해설: LimitRange 기본값 주입과 max 초과 거부

문서:
- https://kubernetes.io/docs/concepts/policy/limit-range/ (`Ctrl+F` `defaultRequest`, 예제 YAML 복사)
- https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

## 핵심
- LimitRange 는 **Pod 생성(admission) 시점**에 기본값을 주입하고 min/max 를 검사한다. 이미 존재하는 Pod 는 영향받지 않는다.
- `default` = 기본 limits, `defaultRequest` = 기본 requests.

## 풀이
```bash
kubectl config use-context k8s
kubectl apply -n lr-demo -f - <<'EOF'
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-mem-limits
spec:
  limits:
  - type: Container
    default: {cpu: 500m, memory: 256Mi}
    defaultRequest: {cpu: 100m, memory: 128Mi}
    max: {cpu: "1", memory: 512Mi}
    min: {cpu: 50m, memory: 64Mi}
EOF
kubectl apply -n lr-demo -f /home/candidate/lr-plain.yaml
kubectl apply -n lr-demo -f /home/candidate/lr-toobig.yaml 2> /home/candidate/lr-error.txt
cat /home/candidate/lr-error.txt
```

## 검증
```bash
kubectl -n lr-demo get pod plain -o jsonpath='{.spec.containers[0].resources}{"\n"}'
kubectl -n lr-demo describe limitrange cpu-mem-limits
kubectl -n lr-demo get pod toobig        # NotFound
```

## 흔한 실수
- `2>` 대신 `>` 로 리다이렉트 (에러 메시지는 stderr).
- `max.cpu: 1` 의 숫자 vs 문자열 (`"1"` 로 따옴표).
- LimitRange 를 먼저 만들지 않고 Pod 를 만들면 기본값이 주입되지 않는다 (순서 중요).
