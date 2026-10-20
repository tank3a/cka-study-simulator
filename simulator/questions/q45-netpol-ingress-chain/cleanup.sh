set -uo pipefail
source "$LIB/common.sh"
kc k8s delete ns shop-np np-other --ignore-not-found --wait=false
