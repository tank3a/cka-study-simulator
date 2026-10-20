# q42 - 해설 (ImagePullBackOff / CrashLoopBackOff / liveness)

## 진단 순서 (공통)
```bash
kubectl -n outage get pods
kubectl -n outage describe pod <pod>     # State/Reason, Events (맨 아래)
kubectl -n outage logs <pod> [--previous]
kubectl -n outage get events --sort-by=.lastTimestamp
```
- `web` -> `ImagePullBackOff`. Events: `manifest for nginx:1.99-alpine not found`. 원인: 존재하지 않는 태그.
- `api` -> `CrashLoopBackOff`. `kubectl logs` : `FATAL: environment variable DB_HOST is not set`. 원인: env 누락.
- `cache` -> Running 인데 RESTARTS 증가. Events: `Liveness probe failed: ... :8080 connection refused` 후 Killing. 원인: probe 포트가 틀림(8080, 실제 80).

## 수정
```bash
kubectl -n outage set image deploy/web web=nginx:1.27
kubectl -n outage set env deploy/api DB_HOST=postgres.outage.svc.cluster.local
kubectl -n outage patch deploy cache --type=json \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/port","value":80}]'
```
(`kubectl edit` 도 가능.)

## 검증
```bash
kubectl -n outage get pods            # 모두 1/1 or 2/2, RESTARTS 0 (새 pod)
kubectl -n outage rollout status deploy/web deploy/api deploy/cache
kubectl -n outage exec deploy/api -- printenv DB_HOST
```

## 포인트
- 상태별 첫 명령: ImagePull -> `describe`, CrashLoop -> `logs --previous`, 재시작 반복 -> `describe` Events 의 probe 실패.
- Deployment 는 template 이 바뀌면 새 ReplicaSet 으로 롤아웃되므로 pod 를 직접 지울 필요 없음.

문서: https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/ , https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/ , https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
