set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp 'mkdir -p /opt/cka; rm -f /opt/cka/ha-external-etcd.yaml'
term_sh 'mkdir -p /home/candidate/answers && rm -f /home/candidate/answers/q81.txt'
