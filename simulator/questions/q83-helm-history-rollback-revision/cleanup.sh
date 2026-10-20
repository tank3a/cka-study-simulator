set -uo pipefail
source "$LIB/common.sh"
helm --kubeconfig "$ADMIN_KUBECONFIG" --kube-context k8s -n helm-ledger uninstall ledger >/dev/null 2>&1
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
term_sh 'rm -f /home/candidate/answers/q83-revision.txt /home/candidate/answers/q83-values.yaml'
