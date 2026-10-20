set -uo pipefail
source "$LIB/assert.sh"
renewed_and_ready() { on_node ek8s-cp test -s /opt/cka/ca-notafter.txt && kc ek8s get --raw=/readyz; }
N=ek8s-cp
check_file "CA expiry written" 1 $N /opt/cka/ca-notafter.txt '^notAfter='
check_node_sh "apiserver-kubelet-client was renewed" 2 $N 'P=/etc/kubernetes/pki; [ "$(openssl x509 -in $P/apiserver-kubelet-client.crt -noout -fingerprint -sha256)" != "$(grep "^apiserver-kubelet-client " /opt/cka/.fp-orig | cut -d" " -f2-)" ]'
check_node_sh "apiserver and front-proxy-client certs unchanged" 1 $N 'P=/etc/kubernetes/pki; [ "$(openssl x509 -in $P/apiserver-kubelet-client.crt -noout -fingerprint -sha256)" != "$(grep "^apiserver-kubelet-client " /opt/cka/.fp-orig | cut -d" " -f2-)" ] || exit 1; for f in apiserver front-proxy-client; do [ "$(openssl x509 -in $P/$f.crt -noout -fingerprint -sha256)" = "$(grep "^$f " /opt/cka/.fp-orig | cut -d" " -f2-)" ] || exit 1; done'
check_node_sh "CA unchanged and apiserver manifest present" 1 $N '[ "$(openssl x509 -in /etc/kubernetes/pki/apiserver-kubelet-client.crt -noout -fingerprint -sha256)" != "$(grep "^apiserver-kubelet-client " /opt/cka/.fp-orig | cut -d" " -f2-)" ] && cmp -s /etc/kubernetes/pki/ca.crt /opt/cka/pki-orig/ca.crt && [ -f /etc/kubernetes/manifests/kube-apiserver.yaml ]'
check_eventually "apiserver healthy after renewal" 1 120 -- renewed_and_ready
