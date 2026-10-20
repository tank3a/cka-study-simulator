set -uo pipefail
source "$LIB/common.sh"
wait_for 120 -- kc ek8s get --raw=/readyz
ns_create ek8s etcd-rs
kc ek8s -n etcd-rs delete deploy restore-keep restore-drop --ignore-not-found
cat <<YAML | kapply ek8s -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: restore-keep, namespace: etcd-rs, labels: {exam.q: "$QID"}}
spec:
  replicas: 1
  selector: {matchLabels: {app: restore-keep}}
  template:
    metadata: {labels: {app: restore-keep}}
    spec:
      containers:
        - {name: c, image: "busybox:1.37", command: ["sleep","3600"]}
YAML
node_sh ek8s-cp '
mkdir -p /opt/cka
rm -rf /var/lib/etcd-restore /opt/cka/etcd-snapshot-prev.db
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /opt/cka/etcd-snapshot-prev.db
'
cat <<YAML | kapply ek8s -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: restore-drop, namespace: etcd-rs, labels: {exam.q: "$QID"}}
spec:
  replicas: 1
  selector: {matchLabels: {app: restore-drop}}
  template:
    metadata: {labels: {app: restore-drop}}
    spec:
      containers:
        - {name: c, image: "busybox:1.37", command: ["sleep","3600"]}
YAML
