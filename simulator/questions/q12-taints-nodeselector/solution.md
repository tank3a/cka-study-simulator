# q12 해설: Taint / Toleration / nodeSelector

문서:
- https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ (`Ctrl+F` `kubectl taint`, `tolerations`)
- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ (`Ctrl+F` `nodeSelector`)

## 1) NoSchedule taint 가 있는 노드 목록
```bash
kubectl config use-context k8s
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints[*].effect
kubectl describe nodes | grep -E '^Name:|^Taints:'
# 파일 저장 (이 환경에서는 control-plane 하나)
kubectl get nodes -o jsonpath='{range .items[?(@.spec.taints)]}{.metadata.name}{" "}{.spec.taints[*].effect}{"\n"}{end}'
echo k8s-control-plane > /home/candidate/noschedule-nodes.txt
```
describe 로 직접 확인한 노드명만 적는다 (taint 가 NoSchedule 인 것).

## 2) control-plane 에서만 실행
control-plane 노드의 taint 는 `node-role.kubernetes.io/control-plane:NoSchedule`, label 은 `node-role.kubernetes.io/control-plane=""`.
```bash
kubectl -n taint-demo edit deploy cp-monitor
```
`spec.template.spec` 아래에 추가:
```yaml
      nodeSelector:
        node-role.kubernetes.io/control-plane: ""
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
```
- nodeSelector 값은 빈 문자열 `""` (label 확인: `kubectl get node k8s-control-plane --show-labels`).
- toleration 만 있으면 "갈 수 있다" 일 뿐이므로 nodeSelector(또는 nodeAffinity)가 함께 있어야 "거기서만" 실행된다.

## 3) label + nodeSelector
```bash
kubectl label node k8s-worker disk=ssd
kubectl -n taint-demo patch deploy fast-store -p '{"spec":{"template":{"spec":{"nodeSelector":{"disk":"ssd"}}}}}'
kubectl -n taint-demo get pods -o wide
```

## 4) taint 추가
```bash
kubectl taint node k8s-worker2 team=blue:PreferNoSchedule
kubectl describe node k8s-worker2 | grep Taints
# 제거: kubectl taint node k8s-worker2 team=blue:PreferNoSchedule-   (또는 team-)
```

## 흔한 실수
- toleration 만 추가하고 nodeSelector 를 안 넣음 -> worker 에도 스케줄됨.
- label 값 `""` 를 `"true"` 로 오인.
- `kubectl taint` 의 구문 `key=value:effect` 에서 `:` 누락.
- nodeSelector 를 Deployment 의 `spec` 에 넣음 (pod template 아래가 맞다).
