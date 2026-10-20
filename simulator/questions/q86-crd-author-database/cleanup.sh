set -uo pipefail
source "$LIB/common.sh"
kc k8s -n crd-author delete database --all --ignore-not-found >/dev/null 2>&1
kc k8s delete crd databases.data.cka.example.com --ignore-not-found
kc k8s delete ns -l exam.q="$QID" --ignore-not-found --wait=true --timeout=90s
term_sh 'rm -f /home/candidate/crd/database-crd.yaml'
