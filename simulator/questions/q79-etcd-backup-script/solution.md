# q79 풀이

```bash
ssh ek8s-cp; sudo -i
# 인증서/엔드포인트는 etcd static pod 매니페스트에서 확인
grep -E 'listen-client-urls|cert-file|key-file|trusted-ca-file' /etc/kubernetes/manifests/etcd.yaml

mkdir -p /opt/cka/backups
cat > /opt/cka/etcd-backup.sh <<'EOF'
#!/bin/bash
set -euo pipefail
OUT=${1:?usage: $0 <snapshot-file>}
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save "$OUT"
etcdutl snapshot status "$OUT" >/dev/null
EOF
chmod +x /opt/cka/etcd-backup.sh
/opt/cka/etcd-backup.sh /opt/cka/backups/etcd-snap.db

etcdutl snapshot status /opt/cka/backups/etcd-snap.db -w json > /opt/cka/etcd-snap-status.json
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint status -w table > /opt/cka/etcd-endpoint-status.txt
```

핵심: `${1:?...}`로 인자 누락 시 에러 종료, `set -e`로 save 실패 전파. v3.6에서 snapshot status는 `etcdutl`이 권장 도구다.

문서: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
