set -uo pipefail
source "$LIB/common.sh"
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
kc k8s delete clusterrolebinding ns-lister metrics-reader --ignore-not-found
kc k8s delete clusterrole ns-lister cm-editor metrics-reader --ignore-not-found
