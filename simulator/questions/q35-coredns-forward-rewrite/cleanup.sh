set -uo pipefail
source "$LIB/common.sh"
NS=dns-lab
# Restore the original Corefile in kube-system, then remove the namespace.
if kc k8s -n "$NS" get cm corefile-backup >/dev/null 2>&1; then
  T=$(mktemp -d)
  kc k8s -n "$NS" get cm corefile-backup -o jsonpath='{.data.Corefile}' > "$T/Corefile"
  if [ -s "$T/Corefile" ]; then
    kc k8s -n kube-system create cm coredns --from-file=Corefile="$T/Corefile" --dry-run=client -o yaml | kc k8s apply -f - >/dev/null
    kc k8s -n kube-system rollout restart deploy/coredns >/dev/null
  fi
  rm -rf "$T"
fi
kc k8s delete ns "$NS" --ignore-not-found --wait=true --timeout=90s >/dev/null
exit 0
