set -uo pipefail
source "$LIB/common.sh"
ns_create k8s csi-lab
kc k8s -n csi-lab delete pvc data --ignore-not-found >/dev/null 2>&1
kc k8s delete storageclass csi-fast --ignore-not-found >/dev/null 2>&1
kc k8s delete csidriver hostpath.csi.cka.example.com --ignore-not-found >/dev/null 2>&1
term_sh 'mkdir -p /home/candidate/answers; rm -f /home/candidate/answers/q90.txt'
