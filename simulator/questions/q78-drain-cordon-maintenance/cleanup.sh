set -uo pipefail
source "$LIB/common.sh"
kc k8s uncordon k8s-worker k8s-worker2 >/dev/null 2>&1
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
