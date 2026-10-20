set -uo pipefail
source "$LIB/common.sh"
kc k8s taint node k8s-worker exam-reserved- >/dev/null 2>&1
kc k8s label node k8s-worker disktype- >/dev/null 2>&1
kc k8s delete storageclass fast-ssd --ignore-not-found
kc k8s delete ns pending-lab --ignore-not-found --wait=false
