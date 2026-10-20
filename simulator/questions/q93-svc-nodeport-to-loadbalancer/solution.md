# q93 풀이 (NodePort -> LoadBalancer, healthCheckNodePort)

문서: https://kubernetes.io/docs/concepts/services-networking/service/

```bash
kubectl config use-context k8s
kubectl -n svc-lb2 edit svc api
```

편집 내용 (삭제/재생성 금지, `edit` 또는 `patch` 사용):

```yaml
spec:
  type: LoadBalancer            # NodePort -> LoadBalancer
  externalTrafficPolicy: Local  # 추가
```

또는 한 줄로:

```bash
kubectl -n svc-lb2 patch svc api -p '{"spec":{"type":"LoadBalancer","externalTrafficPolicy":"Local"}}'
kubectl -n svc-lb2 get svc api -o jsonpath='{.spec.healthCheckNodePort}' > /home/candidate/hc-port.txt
kubectl -n svc-lb2 get svc api        # nodePort 30091 유지, EXTERNAL-IP <pending>
```

- NodePort -> LoadBalancer 는 in-place 변경이 가능하고 기존 nodePort 가 유지된다.
- `externalTrafficPolicy: Local` + LoadBalancer 조합에서만 `healthCheckNodePort` 가 자동 할당된다 (`Cluster` 이면 없음).
- 이 포트로 LB 가 각 노드의 `/healthz` 를 호출해 로컬 Pod 가 있는 노드만 트래픽 대상으로 삼는다.
