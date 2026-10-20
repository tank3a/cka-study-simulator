set -uo pipefail
source "$LIB/common.sh"
M=/etc/kubernetes/manifests/kube-controller-manager.yaml
ns_create ek8s cm-off
# disable two built-in controllers via the --controllers flag. kubeadm already ships
# --controllers=*,bootstrapsigner,tokencleaner, so extend that line (idempotent); insert a new flag only if none exists.
node_sh ek8s-cp "
if grep -q -- '--controllers=' $M; then
  grep -q -- '--controllers=.*-replicaset' $M || sed -i -E 's#(- --controllers=.*)\$#\1,-replicaset,-job#' $M
else
  sed -i 's#^\( *\)- kube-controller-manager\$#&\n\1- --controllers=*,-replicaset,-job#' $M
fi
exit 0"
# wait until the restarted controller-manager carries the flag, then create the workloads
for i in $(seq 1 45); do
  c=$(kc ek8s -n kube-system get pod kube-controller-manager-ek8s-control-plane -o jsonpath='{.spec.containers[0].command}' 2>/dev/null)
  r=$(kc ek8s -n kube-system get pod kube-controller-manager-ek8s-control-plane -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
  case "$c" in *-replicaset*) [ "$r" = "true" ] && break;; esac
  sleep 2
done
kapply ek8s -f - <<'EOT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rs-test
  namespace: cm-off
  labels: {exam.q: q104-controller-manager-disabled}
spec:
  replicas: 2
  selector:
    matchLabels: {app: rs-test}
  template:
    metadata:
      labels: {app: rs-test}
    spec:
      containers:
      - name: web
        image: nginx:1.27
---
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-test
  namespace: cm-off
  labels: {exam.q: q104-controller-manager-disabled}
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: hello
        image: busybox:1.37
        command: ["sh", "-c", "echo done"]
EOT
