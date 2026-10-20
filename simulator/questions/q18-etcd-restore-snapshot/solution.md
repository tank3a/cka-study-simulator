# q18 풀이

```bash
kubectl config use-context ek8s
ssh ek8s-cp
sudo -i
# 1) 복원 (v3.6: etcdutl 사용, etcdctl snapshot restore는 deprecated)
etcdutl snapshot restore /opt/cka/etcd-snapshot-prev.db --data-dir /var/lib/etcd-restore

# 2) static pod 매니페스트에서 etcd-data 볼륨의 hostPath만 변경
vim /etc/kubernetes/manifests/etcd.yaml
#   volumes:
#   - hostPath:
#       path: /var/lib/etcd-restore      # 기존 /var/lib/etcd
#       type: DirectoryOrCreate
#     name: etcd-data
# (컨테이너 안 --data-dir=/var/lib/etcd 와 volumeMounts.mountPath는 그대로 둔다)

# 3) kubelet이 etcd를 재생성할 때까지 대기
watch crictl ps | grep -E 'etcd|apiserver'
kubectl -n etcd-rs get deploy        # restore-keep만 보여야 함
```

함정: `--data-dir` 플래그와 hostPath를 둘 다 바꾸면 마운트가 어긋나 etcd가 안 뜰 수 있다. 하나만 일관되게 바꾼다. 이 문제 후에는 ek8s를 cluster-soft reset 해야 한다.

주의 (stale apiserver 캐시): etcd 만 복원하고 kube-apiserver 를 재시작하지 않으면 apiserver 의 watch 캐시가 복원 전 상태를 계속 보여줘서 `kubectl get deploy` 에 지워진 것이 남아 있을 수 있다 (개별 `get <이름>` 은 NotFound). 이럴 때는 apiserver static pod 를 재시작한다:
```bash
mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/
until ! crictl ps | grep -q kube-apiserver; do sleep 2; done
mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
```
(공식 문서: etcd 복원 시 apiserver 를 먼저 중지하고, 복원 후 다시 시작한다.)

문서: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
