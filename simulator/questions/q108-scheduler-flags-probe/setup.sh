set -uo pipefail
source "$LIB/common.sh"
M=/etc/kubernetes/manifests/kube-scheduler.yaml
# fault 1: typo in --leader-elect (unknown flag, crash). fault 2: --secure-port moved away from the probe port 10259 (visible after fault 1 is fixed)
node_sh ek8s-cp "
sed -i 's#- --leader-elect=true#- --leader-elct=true#' $M
grep -q -- '--secure-port=' $M || sed -i 's#^\( *\)- kube-scheduler\$#&\n\1- --secure-port=10260#' $M
exit 0"
ns_create ek8s sched-flags
kapply ek8s -f - <<'EOT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sched-flag-test
  namespace: sched-flags
  labels: {exam.q: q108-scheduler-flags-probe}
spec:
  replicas: 2
  selector:
    matchLabels: {app: sched-flag-test}
  template:
    metadata:
      labels: {app: sched-flag-test}
    spec:
      containers:
      - name: web
        image: nginx:1.27
EOT
