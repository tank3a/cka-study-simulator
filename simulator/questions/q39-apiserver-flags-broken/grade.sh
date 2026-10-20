set -uo pipefail
source "$LIB/assert.sh"
M=/etc/kubernetes/manifests/kube-apiserver.yaml
check_node_sh "etcd-cafile points to an existing file" 2 ek8s-cp "f=\$(sed -n 's/.*--etcd-cafile=//p' $M); [ -n \"\$f\" ] && [ -f \"\$f\" ]"
check_node_sh "secure-port is 6443" 1 ek8s-cp "grep -q -- '--secure-port=6443' $M"
check_node_sh "etcd-servers untouched" 1 ek8s-cp "grep -q -- '--etcd-servers=https://127.0.0.1:2379' $M && { ! grep -q -- 'ca-bundle.crt' $M || grep -q -- '--secure-port=6443' $M; }"
check_eventually "API server answers /readyz" 2 150 -- kc ek8s get --raw=/readyz
check_sh "kube-apiserver pod Running in kube-system" 1 'kc ek8s -n kube-system get pod -l component=kube-apiserver -o jsonpath="{.items[0].status.phase}" | grep -qx Running'
check_sh "namespace apiserver-fix (cluster data) still exists" 1 'kc ek8s get ns apiserver-fix'
