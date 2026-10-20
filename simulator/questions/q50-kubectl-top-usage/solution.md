# q50 - 해설 (kubectl top)

## 진단 순서
```bash
kubectl top nodes
kubectl -n top-lab top pods --sort-by=cpu
kubectl -n top-lab top pods --sort-by=memory
kubectl -n top-lab top pods --containers
```
`error: Metrics API not available` / `metrics not available yet` 이면 metrics-server pod 확인 (`kubectl -n kube-system get pods | grep metrics`) 후 1분 대기.

## 산출물
```bash
mkdir -p /home/candidate/q50
kubectl -n top-lab top pods --sort-by=cpu --no-headers | head -1 | awk '{print $1}' > /home/candidate/q50/top-cpu-pod.txt
kubectl -n top-lab top pods --sort-by=memory --no-headers | head -1 | awk '{print $1}' > /home/candidate/q50/top-mem-pod.txt
kubectl top nodes > /home/candidate/q50/nodes.txt
cat /home/candidate/q50/*.txt
```
(`--sort-by` 는 내림차순이므로 첫 줄이 최대.)

## 제한 설정
```bash
kubectl -n top-lab set resources deploy/burner-a --limits=cpu=150m     # request 50m 은 limit 이하이므로 그대로 둠
kubectl -n top-lab get deploy burner-a -o jsonpath='{.spec.template.spec.containers[0].resources}'
kubectl -n top-lab top pods --sort-by=cpu       # 약 1분 뒤 burner-a 가 150m 근처
```

## 포인트
- `kubectl top` 은 metrics-server 가 있어야 하고 실시간이 아니라 약 15~60초 지연된 값이다.
- requests 는 스케줄링, limits 는 런타임 상한 (CPU 는 throttle, memory 는 OOMKill).

문서: https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/ , https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/ , https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
