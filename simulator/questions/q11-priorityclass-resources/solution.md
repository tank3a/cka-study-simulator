# q11 해설: PriorityClass + requests/limits

문서:
- https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/ (`Ctrl+F` `kind: PriorityClass`)
- https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

## 1) 가장 높은 user-defined 값 찾기
```bash
kubectl config use-context k8s
kubectl get priorityclass
# 또는: kubectl get pc -o custom-columns=NAME:.metadata.name,VALUE:.value --sort-by=.value
```
`system-*` 는 20억 이상이므로 제외. user-defined 최대값은 `platform-high=50000` -> 새 값은 **49999**.

## 2) PriorityClass 생성 (imperative 가능)
```bash
kubectl create priorityclass business-critical --value=49999 --description="Business critical workloads" --global-default=false
kubectl get pc business-critical
```

## 3) Deployment 수정
```bash
kubectl -n prio-demo set resources deploy/checkout --requests=cpu=100m,memory=64Mi --limits=cpu=200m,memory=128Mi
kubectl -n prio-demo patch deploy checkout -p '{"spec":{"template":{"spec":{"priorityClassName":"business-critical"}}}}'
```
(`set resources` 는 `-c checkout` 로 컨테이너 지정 가능; 컨테이너가 하나면 생략 가능.)
priorityClassName 은 **pod template (`spec.template.spec`)** 아래에 들어간다. Deployment 의 `spec` 에 넣으면 안 된다.

## 검증
```bash
kubectl -n prio-demo rollout status deploy/checkout
kubectl -n prio-demo get pods -o custom-columns=NAME:.metadata.name,PRIO:.spec.priority,CLASS:.spec.priorityClassName
kubectl -n prio-demo describe deploy checkout | grep -A6 -i -E 'Limits|Requests'
```

## 흔한 실수
- 기존 PC 의 값을 `system-cluster-critical` 기준으로 계산.
- `--global-default=true` 로 만들어 이후 만들어지는 모든 Pod 의 기본 우선순위가 바뀜.
- priorityClassName 위치 오류, 또는 이미 존재하는 PC 의 value 를 수정하려는 시도 (value 는 불변).
- requests 가 limits 보다 크면 생성이 거부됨.
