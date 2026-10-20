# q27 풀이 (Service: NodePort + ClusterIP)

문서: https://kubernetes.io/docs/concepts/services-networking/service/

```bash
kubectl config use-context k8s
kubectl -n svc-nodeport get deploy web --show-labels        # 라벨 확인: app=web,tier=frontend

# 방법 1: expose 로 뼈대 생성 후 nodePort 지정
kubectl -n svc-nodeport expose deploy web --name=web-svc --type=NodePort --port=80 --target-port=80 \
  --dry-run=client -o yaml > web-svc.yaml
vim web-svc.yaml        # ports 항목에 nodePort: 30080 추가
kubectl apply -f web-svc.yaml

kubectl -n svc-nodeport expose deploy web --name=web-internal --port=8080 --target-port=80
```

- `expose`는 Deployment의 selector를 그대로 가져온다 (`app=web,tier=frontend`).
- `--node-port` 플래그는 expose에 없으므로 YAML에서 `nodePort: 30080`을 직접 넣는다.
- 검증: `kubectl -n svc-nodeport get svc,endpointslice` 에서 endpoint 3개 확인.
- 함정: selector를 틀리면 Service는 만들어지지만 endpoints가 비어 있다.
- 참고: `--type=LoadBalancer` 는 kind 에 외부 LB 가 없어 EXTERNAL-IP 가 `<pending>` 으로 남지만, nodePort 는 NodePort 와 똑같이 할당된다. spec 만 채점 대상.
