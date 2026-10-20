set -uo pipefail
source "$LIB/common.sh"
wait_for 120 -- kc ek8s get --raw=/readyz
node_sh ek8s-cp '
mkdir -p /opt/cka
rm -f /opt/cka/ca-notafter.txt
[ -d /opt/cka/pki-orig ] || cp -a /etc/kubernetes/pki /opt/cka/pki-orig
for f in apiserver apiserver-kubelet-client front-proxy-client; do
  echo "$f $(openssl x509 -in /opt/cka/pki-orig/$f.crt -noout -fingerprint -sha256)"
done > /opt/cka/.fp-orig
'
