set -uo pipefail
source "$LIB/common.sh"
helm --kubeconfig "$ADMIN_KUBECONFIG" --kube-context k8s -n helm-web uninstall web >/dev/null 2>&1
kc k8s delete ns helm-web --ignore-not-found --wait=true --timeout=90s
term_sh 'helm repo remove cka-charts >/dev/null 2>&1; rm -f /home/candidate/answers/q22-versions.txt'
