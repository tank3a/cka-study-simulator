set -uo pipefail
source "$LIB/common.sh"
wait_for 120 -- kc ek8s get --raw=/readyz
ns_create ek8s etcd-ip
kc ek8s -n etcd-ip delete deploy ledger-keep ledger-drop --ignore-not-found >/dev/null
kapply ek8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger-keep, namespace: etcd-ip, labels: {exam.q: "$QID"}}
spec:
  replicas: 1
  selector: {matchLabels: {app: ledger-keep}}
  template:
    metadata: {labels: {app: ledger-keep}}
    spec:
      containers:
        - {name: c, image: "busybox:1.37", command: ["sleep","3600"]}
YAML
node_sh ek8s-cp '
mkdir -p /opt/cka
rm -rf /var/lib/etcd.old /opt/cka/etcd.yaml.disabled /opt/cka/etcd-pre-incident.db
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /opt/cka/etcd-pre-incident.db
'
kapply ek8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger-drop, namespace: etcd-ip, labels: {exam.q: "$QID"}}
spec:
  replicas: 1
  selector: {matchLabels: {app: ledger-drop}}
  template:
    metadata: {labels: {app: ledger-drop}}
    spec:
      containers:
        - {name: c, image: "busybox:1.37", command: ["sleep","3600"]}
YAML
