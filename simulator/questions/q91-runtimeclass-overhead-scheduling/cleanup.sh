set -uo pipefail
source "$LIB/common.sh"
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
kc k8s delete runtimeclass sandboxed --ignore-not-found
kc k8s label node k8s-worker runtime- >/dev/null 2>&1
term_sh 'rm -f /home/candidate/answers/q91-handlers.txt'
