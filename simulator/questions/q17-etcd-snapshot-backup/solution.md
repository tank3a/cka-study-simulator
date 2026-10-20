# q17 풀이

```bash
kubectl config use-context ek8s
ssh ek8s-cp
sudo -i
# 인증서 경로/엔드포인트는 매니페스트에서 확인
grep -E 'listen-client|cert-file|key-file|trusted-ca' /etc/kubernetes/manifests/etcd.yaml
mkdir -p /opt/cka
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/cka/etcd-backup.db
etcdutl snapshot status /opt/cka/etcd-backup.db -w table     # 검증
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  member list | wc -l > /opt/cka/etcd-members.txt
```

핵심: `--cacert/--cert/--key`는 etcd.yaml의 `--trusted-ca-file`, `--cert-file`, `--key-file` 값을 그대로 사용. `snapshot status`는 etcdutl 사용(etcdctl의 status는 deprecated). 클러스터 상태는 건드리지 않는다.

문서: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
