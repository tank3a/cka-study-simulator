# q106 - 해설 (APIService -> Service 포트 불일치)

## 진단 순서
1. `kubectl top nodes` -> `Metrics API not available`
2. `kubectl -n kube-system get pods -l k8s-app=metrics-server` -> Running 1/1 (Pod 자체는 정상)
3. `kubectl get apiservice v1beta1.metrics.k8s.io -o yaml` -> `Available=False`, reason `FailedDiscoveryCheck`, message `dial tcp <ClusterIP/PodIP>:8443: connect: connection refused`
4. Service 와 컨테이너 포트 비교:
   ```bash
   kubectl -n kube-system get svc metrics-server -o yaml | grep -A4 ports
   kubectl -n kube-system get deploy metrics-server -o jsonpath='{.spec.template.spec.containers[0].ports}'
   kubectl -n kube-system get endpointslices -l kubernetes.io/service-name=metrics-server
   ```
   Service `targetPort: 8443`, 컨테이너 포트는 `https`(10250).

## 수정
```bash
kubectl -n kube-system patch svc metrics-server --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":"https"}]'
kubectl get apiservice v1beta1.metrics.k8s.io      # True (몇 초 걸림)
```

## 산출물
```bash
mkdir -p ~/q106
echo service/metrics-server > ~/q106/cause.txt
kubectl top pods -n kube-system --containers > ~/q106/pods-top.txt
```

## 포인트
- Pod 이 Ready 인데 API 가 안 되면 중간 고리(APIService -> Service -> Endpoints -> targetPort)를 하나씩 본다. 서비스 디버깅(q44)과 같은 방법.
- reason 이 MissingEndpoints 였다면 selector/Pod 문제, FailedDiscoveryCheck + connection refused 는 포트 문제.

문서: https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/ , https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/ , https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/
