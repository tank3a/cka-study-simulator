set -uo pipefail
source "$LIB/common.sh"
node_sh ek8s-cp '
if [ -d /opt/cka/pki-orig ]; then
  cp -a /opt/cka/pki-orig/apiserver-kubelet-client.crt /opt/cka/pki-orig/apiserver-kubelet-client.key /etc/kubernetes/pki/
fi
rm -f /opt/cka/ca-notafter.txt
true
'
