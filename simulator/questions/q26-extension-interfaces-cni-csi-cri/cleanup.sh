set -uo pipefail
source "$LIB/common.sh"
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
kc k8s delete runtimeclass standard-runc --ignore-not-found
term_sh 'rm -f /home/candidate/answers/q26.txt'
