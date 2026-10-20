# q80 풀이

```bash
kubectl config use-context ek8s
ssh ek8s-cp; sudo -i

# 1) etcd 중지: 매니페스트를 밖으로 이동 -> kubelet이 static pod를 내린다
mv /etc/kubernetes/manifests/etcd.yaml /opt/cka/etcd.yaml.disabled
watch crictl ps | grep etcd          # etcd 컨테이너가 사라질 때까지 (apiserver도 곧 내려간다)

# 2) 손상된 데이터 보존
mv /var/lib/etcd /var/lib/etcd.old

# 3) 같은 경로로 복원 (v3.6: etcdutl)
etcdutl snapshot restore /opt/cka/etcd-pre-incident.db --data-dir /var/lib/etcd

# 4) 매니페스트 원복 (수정 없음)
mv /opt/cka/etcd.yaml.disabled /etc/kubernetes/manifests/etcd.yaml
crictl ps | grep -E 'etcd|apiserver'
kubectl -n etcd-ip get deploy         # ledger-keep만 존재
```

q18과의 차이: q18은 새 data-dir + 매니페스트 hostPath 수정 방식이고, 이 문제는 매니페스트를 건드리지 않고 같은 경로에 복원한다. 매니페스트를 먼저 치우지 않고 디렉터리를 바꾸면 실행 중인 etcd가 기존 파일을 계속 쓰므로 순서를 지킨다. 이 문제 후에는 ek8s를 cluster-soft reset 한다.

주의 (stale apiserver 캐시): etcd 만 복원하고 kube-apiserver 를 재시작하지 않으면 apiserver 의 watch 캐시가 복원 전 상태를 계속 보여줘서 `kubectl get deploy` 에 지워진 것이 남아 있을 수 있다 (개별 `get <이름>` 은 NotFound). 이럴 때는 apiserver static pod 를 재시작한다:
```bash
mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/
until ! crictl ps | grep -q kube-apiserver; do sleep 2; done
mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
```
(공식 문서: etcd 복원 시 apiserver 를 먼저 중지하고, 복원 후 다시 시작한다.)

문서: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
