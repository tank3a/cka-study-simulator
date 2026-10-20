set -uo pipefail
source "$LIB/common.sh"
term_sh 'rm -rf /home/candidate/q105'
# restore the flag if the candidate did not
if ! kc k8s -n kube-system get deploy metrics-server -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q 'kubelet-insecure-tls'; then
  kc k8s -n kube-system patch deploy metrics-server --type=json -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kc k8s -n kube-system rollout status deploy/metrics-server --timeout=90s >/dev/null 2>&1 || true
