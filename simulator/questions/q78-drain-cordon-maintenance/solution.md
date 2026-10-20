# q78 풀이

```bash
kubectl config use-context k8s
kubectl get nodes                        # k8s-worker: Ready,SchedulingDisabled
kubectl uncordon k8s-worker

# drain은 cordon을 포함한다. DaemonSet은 무시, emptyDir 데이터 삭제 허용, 컨트롤러 없는 Pod(solo)는 --force 필요
kubectl drain k8s-worker2 --ignore-daemonsets --delete-emptydir-data --force

kubectl get nodes                        # k8s-worker2: SchedulingDisabled 유지 (uncordon 하지 않음)
kubectl -n drain-lab get pods -o wide
```

함정:
- 순서가 중요하다: k8s-worker가 cordon된 채로 worker2를 drain하면 Pod가 갈 곳이 없어 Pending이 된다.
- `--ignore-daemonsets`가 없으면 drain이 멈추고, `--delete-emptydir-data`가 없으면 emptyDir Pod 때문에 거부되며, 컨트롤러 없는 Pod는 `--force` 없이는 거부된다.
- 점검이 끝나면 `kubectl uncordon k8s-worker2` (이 문제에서는 하지 않는다).

문서: https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/
