set -uo pipefail
source "$LIB/common.sh"
helm --kubeconfig "$ADMIN_KUBECONFIG" --kube-context k8s -n helm-notes uninstall notes >/dev/null 2>&1
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
term_sh 'helm repo remove platform >/dev/null 2>&1; rm -f /home/candidate/answers/q82-version.txt /home/candidate/answers/q82-values.yaml; true'
