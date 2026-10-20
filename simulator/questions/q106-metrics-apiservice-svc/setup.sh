set -uo pipefail
source "$LIB/common.sh"
term_sh 'rm -rf /home/candidate/q106'
# Service targetPort points at a port nothing listens on (idempotent replace)
out=$(kc k8s -n kube-system patch svc metrics-server --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":8443}]')
echo "$out"
# kube-apiserver keeps its long-lived HTTP/2 connection to the metrics-server Pod, so the wrong targetPort has no visible effect
# until that connection drops: restart the Pod once so that the API becomes unavailable
case "$out" in *"no change"*) ;; *)
  kc k8s -n kube-system rollout restart deploy/metrics-server >/dev/null
  kc k8s -n kube-system rollout status deploy/metrics-server --timeout=90s >/dev/null 2>&1 || true;;
esac
