set -uo pipefail
source "$LIB/common.sh"
ns_create k8s cr-a
ns_create k8s cr-b
kapply k8s -f - <<YAML
apiVersion: v1
kind: ServiceAccount
metadata: {name: deployer, namespace: cr-a, labels: {exam.q: "$QID"}}
YAML
kc k8s delete clusterrolebinding ns-lister metrics-reader --ignore-not-found >/dev/null
kc k8s delete clusterrole ns-lister cm-editor metrics-reader --ignore-not-found >/dev/null
