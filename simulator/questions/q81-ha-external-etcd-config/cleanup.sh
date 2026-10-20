set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp 'rm -f /opt/cka/ha-external-etcd.yaml'
term_sh 'rm -f /home/candidate/answers/q81.txt'
