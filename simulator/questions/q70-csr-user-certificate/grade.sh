set -uo pipefail
source "$LIB/assert.sh"
D=/home/candidate/csr
check_file "private key exists" 1 term $D/dana.key 'PRIVATE KEY'
check_file "csr file exists" 1 term $D/dana.csr 'CERTIFICATE REQUEST'
check_jsonpath "CSR object uses the client signer" 1 k8s csr/dana '{.spec.signerName}' kubernetes.io/kube-apiserver-client
check_jsonpath "CSR lifetime 86400s" 1 k8s csr/dana '{.spec.expirationSeconds}' 86400
check_match "CSR approved" 1 'Approved' -- kc k8s get csr dana -o "jsonpath={.status.conditions[*].type}"
check_sh "certificate issued with CN=dana and O=devs" 2 'S=$(term_sh "openssl x509 -in /home/candidate/csr/dana.crt -noout -subject"); echo "$S" | grep -Eq "CN ?= ?dana" && echo "$S" | grep -Eq "O ?= ?devs"'
check_sh "certificate matches the private key" 1 'A=$(term_sh "openssl x509 -in /home/candidate/csr/dana.crt -noout -modulus | md5sum"); B=$(term_sh "openssl rsa -in /home/candidate/csr/dana.key -noout -modulus | md5sum"); term_sh "test -s /home/candidate/csr/dana.crt" && [ -n "$A" ] && [ "$A" = "$B" ]'
check_sh "dana can read pods in csr-lab, cannot delete them" 1 '[ "$(kc k8s auth can-i get pods -n csr-lab --as=dana)" = yes ] && [ "$(kc k8s auth can-i delete pods -n csr-lab --as=dana)" = no ]'
check_sh "dana has no access in default" 1 '[ "$(kc k8s auth can-i get pods -n csr-lab --as=dana)" = yes ] && [ "$(kc k8s auth can-i get pods -n default --as=dana)" = no ]'
