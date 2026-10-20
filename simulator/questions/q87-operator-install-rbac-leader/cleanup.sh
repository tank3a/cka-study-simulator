set -uo pipefail
source "$LIB/common.sh"
kc k8s delete clusterrolebinding sync-operator --ignore-not-found
kc k8s delete clusterrole sync-operator --ignore-not-found
kc k8s -n ops-system delete syncjob --all --ignore-not-found >/dev/null 2>&1
kc k8s delete crd syncjobs.sync.cka.example.com --ignore-not-found
kc k8s delete ns ops-system --ignore-not-found --wait=true --timeout=90s
