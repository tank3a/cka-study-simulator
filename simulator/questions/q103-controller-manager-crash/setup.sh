set -uo pipefail
source "$LIB/common.sh"
M=/etc/kubernetes/manifests/kube-controller-manager.yaml
ns_create ek8s cm-crash
# fault 1: misspelled flag (unknown flag -> crash). fault 2: service account key path does not exist (visible after fault 1 is fixed)
node_sh ek8s-cp "
sed -i 's#--use-service-account-credentials=true#--use-service-account-credential=true#' $M
sed -i 's#--service-account-private-key-file=/etc/kubernetes/pki/sa.key\$#--service-account-private-key-file=/etc/kubernetes/pki/sa.key.old#' $M
exit 0"
# wait until the controller-manager is really down before creating the Deployment (otherwise it would still create the ReplicaSet)
for i in $(seq 1 45); do
  r=$(kc ek8s -n kube-system get pod kube-controller-manager-ek8s-control-plane -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
  [ "$r" = "true" ] || break
  sleep 2
done
kapply ek8s -f - <<'EOT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cm-test
  namespace: cm-crash
  labels: {exam.q: q103-controller-manager-crash}
spec:
  replicas: 3
  selector:
    matchLabels: {app: cm-test}
  template:
    metadata:
      labels: {app: cm-test}
    spec:
      containers:
      - name: web
        image: nginx:1.27
EOT
