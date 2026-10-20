set -uo pipefail
source "$LIB/common.sh"
kc k8s delete ingressclass fix-nginx fix-haproxy --ignore-not-found >/dev/null
kc k8s delete ns ing-fix --ignore-not-found --wait=true --timeout=90s >/dev/null
exit 0
