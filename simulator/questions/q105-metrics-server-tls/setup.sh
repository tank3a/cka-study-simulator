set -uo pipefail
source "$LIB/common.sh"
term_sh 'rm -rf /home/candidate/q105'
# remove --kubelet-insecure-tls from the metrics-server args (kind kubelets use self-signed serving certs); idempotent
args=$(kc k8s -n kube-system get deploy metrics-server -o jsonpath='{range .spec.template.spec.containers[0].args[*]}{@}{"\n"}{end}' 2>/dev/null)
idx=$(printf '%s\n' "$args" | grep -n -x -- '--kubelet-insecure-tls' | head -1 | cut -d: -f1)
if [ -n "$idx" ]; then
  kc k8s -n kube-system patch deploy metrics-server --type=json -p "[{\"op\":\"remove\",\"path\":\"/spec/template/spec/containers/0/args/$((idx-1))\"}]"
  # the new Pod never becomes Ready, and maxUnavailable=0 would keep the OLD (working) Pod serving: the fault would be invisible.
  # Scale to 0 and back so that only the broken Pod exists.
  kc k8s -n kube-system scale deploy metrics-server --replicas=0 >/dev/null
  wait_for 60 -- bash -c '[ -z "$(kubectl --kubeconfig "$0" --context k8s -n kube-system get pods -l k8s-app=metrics-server -o name)" ]' "$ADMIN_KUBECONFIG"
  kc k8s -n kube-system scale deploy metrics-server --replicas=1 >/dev/null
fi
