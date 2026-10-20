set -uo pipefail
source "$LIB/common.sh"
ns_create k8s rc-lab
kc k8s label node k8s-worker runtime=sandbox --overwrite >/dev/null
kc k8s delete runtimeclass sandboxed --ignore-not-found >/dev/null 2>&1
kc k8s -n rc-lab delete deploy sbx --ignore-not-found >/dev/null 2>&1
term_sh 'mkdir -p /home/candidate/answers; rm -f /home/candidate/answers/q91-handlers.txt'
