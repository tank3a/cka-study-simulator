set -uo pipefail
source "$LIB/assert.sh"
M=/etc/kubernetes/manifests/kube-controller-manager.yaml
check_node_sh "no misspelled --use-service-account-credential flag left" 2 ek8s-cp "! grep -qE -- '--use-service-account-credential([^s]|\$)' $M"
check_node_sh "service-account-private-key-file points to an existing file" 1 ek8s-cp 'f=$(sed -n "s/.*--service-account-private-key-file=//p" '"$M"'); [ -n "$f" ] && [ -f "$f" ]'
check_eventually "kube-controller-manager pod is Ready" 2 120 -- kc ek8s -n kube-system wait --for=condition=Ready pod/kube-controller-manager-ek8s-control-plane --timeout=5s
check_eventually "cm-test has 3 available replicas" 2 120 -- kc ek8s -n cm-crash wait --for=condition=Available deploy/cm-test --timeout=5s
check_sh "ReplicaSet owned by cm-test exists (Deployment not replaced)" 1 'kc ek8s -n cm-crash get rs -o jsonpath="{.items[*].metadata.ownerReferences[*].name}" | grep -qw cm-test'
check_sh "manifest still in /etc/kubernetes/manifests (static pod mirror present)" 1 'kc ek8s -n cm-crash wait --for=condition=Available deploy/cm-test --timeout=1s >/dev/null && kc ek8s -n kube-system get pod kube-controller-manager-ek8s-control-plane -o name'
