set -uo pipefail
source "$LIB/common.sh"
# IngressClass objects are cluster-scoped; the candidate-created one has no exam label.
kc k8s delete ingressclass public internal --ignore-not-found >/dev/null
kc k8s delete ns ing-class --ignore-not-found --wait=true --timeout=90s >/dev/null
exit 0
