set -uo pipefail
source "$LIB/common.sh"
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
kc k8s delete clusterrolebinding -l exam.q="$QID" --ignore-not-found
kc k8s delete clusterrolebinding reporter-nodes --ignore-not-found
kc k8s delete clusterrole reporter-nodes --ignore-not-found
term_sh 'rm -f /home/candidate/answers/q16-bindings.txt'
