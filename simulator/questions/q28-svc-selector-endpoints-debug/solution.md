# q28 풀이 (Service selector / targetPort 디버깅)

문서: https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/

```bash
kubectl config use-context k8s
kubectl -n svc-debug get svc api -o wide           # SELECTOR 확인
kubectl -n svc-debug get endpointslice -l kubernetes.io/service-name=api   # ENDPOINTS 가 비어 있음
kubectl -n svc-debug get pods --show-labels         # Pod 라벨은 app=api,tier=backend
kubectl -n svc-debug get deploy api -o jsonpath='{.spec.template.spec.containers[0].ports}'  # 80

kubectl -n svc-debug edit svc api
#   selector: {app: api}      (api-server -> api)
#   targetPort: 80            (8080 -> 80)

kubectl -n svc-debug get pods -l app=api -o jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}' \
  > /home/candidate/api-endpoints.txt
# 또는 EndpointSlice 에서: kubectl -n svc-debug get endpointslice -l kubernetes.io/service-name=api \
#   -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}'
```

- 함정 2개: selector 불일치(endpoints 비어 있음), targetPort 오류(endpoints는 있으나 connection refused).
- Service만 수정. Deployment 라벨을 바꾸면 감점.
