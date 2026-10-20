# q48 - 해설 (readiness 실패 + named port 불일치)

## 진단 순서
```bash
kubectl -n svc-ready get pods,svc,endpoints          # pods 0/1 Ready, ENDPOINTS <none>
kubectl -n svc-ready describe pod -l app=portal       # Readiness probe failed: HTTP probe failed with statuscode: 404
kubectl -n svc-ready describe svc portal              # Endpoints: <none>
kubectl -n svc-ready get svc portal -o yaml | grep -A4 ports
kubectl -n svc-ready get deploy portal -o yaml | grep -B2 -A6 'ports:'
```
원인 2가지:
1. readinessProbe 가 `/healthz` 를 요청하는데 nginx 는 404 -> pod NotReady -> endpoints 에서 제외.
2. Service `targetPort: http` 인데 컨테이너 포트 이름은 `web` -> 이름이 해석되지 않아 endpoint 포트가 생기지 않음.

## 수정
```bash
kubectl -n svc-ready patch deploy portal --type=json -p='[
 {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"},
 {"op":"replace","path":"/spec/template/spec/containers/0/ports/0/name","value":"http"}]'
```
(또는 Service `targetPort: web` 으로 변경. 이 경우 Deployment 는 probe 만 수정.)

## 검증
```bash
kubectl -n svc-ready rollout status deploy/portal
kubectl -n svc-ready get endpoints portal
curl -s -o /dev/null -w '%{http_code}\n' http://<노드 IP>:30048/        # 200  (exam 에서는 kubectl get nodes -o wide 의 INTERNAL-IP)
```

## 포인트
- Service 가 안 되면 Endpoints 부터. Endpoints 가 비면 selector / pod Ready / named port 3가지를 차례로.
- NodePort 는 모든 노드에서 열린다 (kube-proxy).

문서: https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/ , https://kubernetes.io/docs/concepts/services-networking/service/ , https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
