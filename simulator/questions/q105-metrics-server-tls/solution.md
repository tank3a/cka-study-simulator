# q105 - 해설 (metrics-server TLS 오류)

## 진단 순서 (metrics pipeline: kubelet -> metrics-server -> APIService -> kubectl top)
1. `kubectl top nodes` -> `error: Metrics API not available`
2. `kubectl get apiservice v1beta1.metrics.k8s.io` -> `AVAILABLE=False (MissingEndpoints 또는 FailedDiscoveryCheck)`
3. `kubectl -n kube-system get deploy,pods -l k8s-app=metrics-server` -> Pod 이 `0/1` (readiness 실패)
4. `kubectl -n kube-system logs deploy/metrics-server` -> `x509: cannot validate certificate for <노드IP> because it doesn't contain any IP SANs` (kubelet 서빙 인증서 검증 실패)

## 수정
```bash
kubectl -n kube-system edit deploy metrics-server
# spec.template.spec.containers[0].args 에 추가:  - --kubelet-insecure-tls
kubectl -n kube-system rollout status deploy/metrics-server
```
(실무에서는 kubelet 서빙 인증서를 정식 CA 로 발급하는 것이 정석이다. 시험/랩에서는 이 플래그가 일반적인 해결책.)

## 검증과 산출물
```bash
kubectl get apiservice v1beta1.metrics.k8s.io        # True
mkdir -p ~/q105
printf '%s\n' --kubelet-insecure-tls > ~/q105/cause.txt
kubectl top nodes | tee ~/q105/nodes.txt
```
(`echo` 는 `--...` 를 옵션으로 오해할 수 있어 `printf` 사용)

## 포인트
- kubectl top 이 실패하면 `apiservice` 상태 -> metrics-server Pod/로그 순서로 본다.
- Available=False 의 reason 이 MissingEndpoints 면 Pod 미준비, FailedDiscoveryCheck 면 Service/포트/네트워크 문제.

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/ , https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/
