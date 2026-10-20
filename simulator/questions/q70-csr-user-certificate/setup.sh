set -uo pipefail
source "$LIB/common.sh"
ns_create k8s csr-lab
kc k8s delete csr dana --ignore-not-found >/dev/null
term_sh 'rm -rf /home/candidate/csr; mkdir -p /home/candidate/csr'
