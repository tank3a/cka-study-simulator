set -uo pipefail
source "$LIB/common.sh"
M=/etc/kubernetes/manifests/kube-scheduler.yaml
# fault 1: image tag does not exist. fault 2: kubeconfig path typo (visible only after fault 1 is fixed)
node_sh ek8s-cp "
sed -i -E 's#(image: .*kube-scheduler:)[^ ]+#\1v1.34.99#' $M
sed -i 's#--kubeconfig=/etc/kubernetes/scheduler\\.conf\$#--kubeconfig=/etc/kubernetes/scheduler-conf.yaml#' $M
exit 0"
ns_create ek8s sched-fix
kapply ek8s -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sched-test
  namespace: sched-fix
  labels: {exam.q: q40-scheduler-down}
spec:
  replicas: 2
  selector:
    matchLabels: {app: sched-test}
  template:
    metadata:
      labels: {app: sched-test}
    spec:
      containers:
      - name: web
        image: nginx:1.27
EOF
