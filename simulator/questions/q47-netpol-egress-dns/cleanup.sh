set -uo pipefail
source "$LIB/common.sh"
kc k8s delete ns egress-dns --ignore-not-found --wait=false
