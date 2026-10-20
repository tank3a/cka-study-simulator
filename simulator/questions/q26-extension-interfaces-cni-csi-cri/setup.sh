set -uo pipefail
source "$LIB/common.sh"
ns_create k8s ext-if
kc k8s delete runtimeclass standard-runc --ignore-not-found >/dev/null
term_sh 'mkdir -p /home/candidate/answers && rm -f /home/candidate/answers/q26.txt'
