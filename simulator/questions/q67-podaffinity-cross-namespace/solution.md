# q67 해설: podAffinity 로 같은 노드 배치, 다른 namespace 대상 podAntiAffinity

문서:
- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ (`Ctrl+F` `Inter-pod affinity and anti-affinity`, `namespaces`)

## 핵심
- podAffinity/podAntiAffinity 의 `labelSelector` 는 **기본적으로 Pod 자신의 namespace** 의 Pod 만 본다. 다른 namespace 의 Pod 를 피하려면 `namespaces: [aff2-batch]` (또는 `namespaceSelector`) 가 필요하다.
- `batch-noisy` 는 `k8s-worker` 에 있으므로 `cache` 는 `k8s-worker2` 로 가야 한다. `frontend` 는 `cache` 와 같은 노드(`k8s-worker2`).
- 순서 중요: affinity 는 `IgnoredDuringExecution` 이다. `cache` 를 먼저 옮기고(재배포) 그 다음 `frontend` 를 롤아웃해야 마지막 배치가 일치한다.
  (frontend 먼저 수정하면 cache 가 이동한 뒤 frontend 는 옛 노드에 남는다 -> `kubectl rollout restart deploy/frontend` 로 재배치.)

## 풀이
```bash
kubectl config use-context k8s
kubectl -n aff2 patch deploy cache -p '{"spec":{"template":{"spec":{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app":"batch-noisy"}},"namespaces":["aff2-batch"],"topologyKey":"kubernetes.io/hostname"}]}}}}}}'
kubectl -n aff2 rollout status deploy/cache
kubectl -n aff2 patch deploy frontend -p '{"spec":{"template":{"spec":{"affinity":{"podAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app":"cache"}},"topologyKey":"kubernetes.io/hostname"}]}}}}}}'
kubectl -n aff2 rollout status deploy/frontend
```

## 검증
```bash
kubectl -n aff2 get pods -o wide
kubectl -n aff2-batch get pods -o wide
```

## 흔한 실수
- `namespaces` 누락 -> 같은 namespace 에서 `app=batch-noisy` 를 찾으므로 규칙이 무의미해져 cache 가 worker 에 남을 수 있다.
- podAffinity 와 podAntiAffinity 를 혼동 / `topologyKey` 누락 (필수).
- 최종 배치를 확인하지 않음 (frontend 가 cache 와 다른 노드).
