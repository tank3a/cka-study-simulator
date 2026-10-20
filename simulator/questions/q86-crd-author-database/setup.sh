set -uo pipefail
source "$LIB/common.sh"
ns_create k8s crd-author
kc k8s -n crd-author delete database orders --ignore-not-found >/dev/null 2>&1
kc k8s delete crd databases.data.cka.example.com --ignore-not-found >/dev/null 2>&1
term_sh 'mkdir -p /home/candidate/crd; rm -f /home/candidate/crd/database-crd.yaml'
