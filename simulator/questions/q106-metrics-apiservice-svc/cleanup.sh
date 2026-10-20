set -uo pipefail
source "$LIB/common.sh"
term_sh 'rm -rf /home/candidate/q106'
kc k8s -n kube-system patch svc metrics-server --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":"https"}]'
