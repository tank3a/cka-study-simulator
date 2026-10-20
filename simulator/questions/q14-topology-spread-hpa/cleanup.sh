set -uo pipefail
source "$LIB/common.sh"
kc k8s label node k8s-worker zone- >/dev/null 2>&1
kc k8s label node k8s-worker2 zone- >/dev/null 2>&1
exit 0
