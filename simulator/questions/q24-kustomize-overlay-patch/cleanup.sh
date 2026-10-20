set -uo pipefail
source "$LIB/common.sh"
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
term_sh 'rm -rf /home/candidate/kustomize'
