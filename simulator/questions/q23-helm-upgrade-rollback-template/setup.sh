set -uo pipefail
source "$LIB/common.sh"
H="helm --kubeconfig $ADMIN_KUBECONFIG --kube-context k8s"
ns_create k8s helm-app
term_sh 'mkdir -p /home/candidate/helm/cka-app/templates /home/candidate/answers; rm -f /home/candidate/answers/preview.yaml'
for f in Chart.yaml values.yaml templates/deployment.yaml templates/service.yaml; do
  term_put "/home/candidate/helm/cka-app/$f" < "$QDIR/chart/$f"
done
term_put /home/candidate/helm/preview-values.yaml <<'YAML'
replicaCount: 4
message: "preview build"
service:
  type: NodePort
  nodePort: 30099
YAML
if ! $H -n helm-app status shop >/dev/null 2>&1; then
  $H -n helm-app install shop "$QDIR/chart" --set replicaCount=1 --set message=prod --wait --timeout 90s
  $H -n helm-app upgrade shop "$QDIR/chart" --set replicaCount=2 --set message=prod --set image.tag=1.99.99-does-not-exist
fi
