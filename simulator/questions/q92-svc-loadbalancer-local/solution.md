# q92 풀이 (Service type LoadBalancer + externalTrafficPolicy Local)

문서: https://kubernetes.io/docs/concepts/services-networking/service/

```bash
kubectl config use-context k8s
kubectl -n svc-lb get deploy shop --show-labels      # app=shop,tier=web

# expose 로 뼈대를 만든 뒤 spec 항목 추가
kubectl -n svc-lb expose deploy shop --name=shop-lb --type=LoadBalancer --port=80 --target-port=80 \
  --dry-run=client -o yaml > lb.yaml
vim lb.yaml
```

`spec` 에 다음을 추가한다:

```yaml
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  loadBalancerSourceRanges:
  - 10.0.0.0/8
```

```bash
kubectl apply -f lb.yaml
kubectl -n svc-lb get svc shop-lb          # EXTERNAL-IP 는 <pending> (kind 에는 LB 구현체 없음)
kubectl -n svc-lb get svc shop-lb -o jsonpath='{.spec.ports[0].nodePort}' > /home/candidate/shop-lb-nodeport.txt
```

- LoadBalancer 타입도 NodePort(와 ClusterIP)를 자동 할당한다. 클라우드가 없으면 EXTERNAL-IP 만 pending 으로 남는다.
- `externalTrafficPolicy: Local` 이면 해당 노드에 Pod 가 있을 때만 응답한다 (소스 IP 보존, 추가 hop 없음). Pod 가 없는 노드는 연결이 끊긴다.
- `Local` 로 설정하면 `healthCheckNodePort` 가 자동 할당된다.
- 함정: `loadBalancerSourceRanges` 는 클라우드 LB 방화벽용 필드이며 kube-proxy NodePort 경로에는 적용되지 않는다.
