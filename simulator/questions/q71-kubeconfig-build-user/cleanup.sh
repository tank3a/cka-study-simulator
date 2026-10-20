set -uo pipefail
source "$LIB/common.sh"
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
kc k8s delete csr ravi-kcfg --ignore-not-found
term_sh 'rm -rf /home/candidate/kc /home/candidate/creds /home/candidate/answers/q71-contexts.txt'
