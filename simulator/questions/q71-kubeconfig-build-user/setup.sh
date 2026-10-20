set -uo pipefail
source "$LIB/common.sh"
ns_create k8s kcfg
kc k8s -n kcfg create rolebinding ravi-view --clusterrole=view --user=ravi --dry-run=client -o yaml | kapply k8s -f - >/dev/null
if ! term_sh 'test -f /home/candidate/creds/ravi.crt'; then
  term_sh 'mkdir -p /home/candidate/creds; openssl genrsa -out /home/candidate/creds/ravi.key 2048 2>/dev/null; openssl req -new -key /home/candidate/creds/ravi.key -subj "/CN=ravi" -out /tmp/ravi.csr'
  REQ=$(term_sh 'base64 -w0 /tmp/ravi.csr')
  kc k8s delete csr ravi-kcfg --ignore-not-found >/dev/null
  kapply k8s -f - <<YAML
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata: {name: ravi-kcfg, labels: {exam.q: "$QID"}}
spec:
  request: $REQ
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 604800
  usages: [client auth]
YAML
  kc k8s certificate approve ravi-kcfg >/dev/null
  CERT=""
  for i in 1 2 3 4 5 6 7 8 9 10; do
    CERT=$(kc k8s get csr ravi-kcfg -o jsonpath='{.status.certificate}')
    [ -n "$CERT" ] && break
    sleep 2
  done
  echo "$CERT" | term_put /home/candidate/creds/ravi.crt.b64
  term_sh 'base64 -d /home/candidate/creds/ravi.crt.b64 > /home/candidate/creds/ravi.crt'
fi
term_sh 'mkdir -p /home/candidate/kc /home/candidate/answers; rm -f /home/candidate/kc/ravi.kubeconfig /home/candidate/answers/q71-contexts.txt'
