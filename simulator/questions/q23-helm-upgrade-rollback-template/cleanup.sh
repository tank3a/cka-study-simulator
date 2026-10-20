set -uo pipefail
source "$LIB/common.sh"
helm --kubeconfig "$ADMIN_KUBECONFIG" --kube-context k8s -n helm-app uninstall shop >/dev/null 2>&1
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
term_sh 'rm -rf /home/candidate/helm/cka-app /home/candidate/helm/preview-values.yaml /home/candidate/answers/preview.yaml'
