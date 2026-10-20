set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp 'rm -f /opt/cka/init-config.yaml /opt/cka/init-images.txt'
