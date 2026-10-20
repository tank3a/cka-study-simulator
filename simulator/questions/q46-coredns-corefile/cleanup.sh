set -uo pipefail
source "$LIB/common.sh"
cf=$(kc k8s -n kube-system get cm coredns -o jsonpath='{.data.Corefile}')
tmp=$(mktemp)
printf '%s\n' "$cf" | sed -e 's/kubernetes cluster\.lcl/kubernetes cluster.local/' -e 's#forward \. 10\.255\.255\.1#forward . /etc/resolv.conf#' > "$tmp"
kc k8s -n kube-system create configmap coredns --from-file=Corefile="$tmp" --dry-run=client -o yaml | kc k8s apply -f - >/dev/null
rm -f "$tmp"
kc k8s -n kube-system rollout restart deploy/coredns >/dev/null
kc k8s delete ns dns-fix --ignore-not-found --wait=false
