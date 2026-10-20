set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp 'rm -f /opt/cka/fixed-init.yaml /opt/cka/broken-init.yaml /opt/cka/.broken.sha'
