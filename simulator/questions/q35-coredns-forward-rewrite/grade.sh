set -uo pipefail
source "$LIB/assert.sh"
NS=dns-lab
CORP=$(kc k8s -n "$NS" get svc corp-dns -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
DBIP=$(kc k8s -n "$NS" get svc db -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
check_sh "Corefile has a corp.internal server block forwarding to the corp-dns ClusterIP" 2 '[ -n "'"$CORP"'" ] && c=$(kc k8s -n kube-system get cm coredns -o jsonpath="{.data.Corefile}") && echo "$c" | grep -q "corp.internal" && echo "$c" | grep -q "forward" && echo "$c" | grep -q "'"$CORP"'"'
# "keeps working" checks only count once the Corefile was changed (untouched state must not score)
M='kc k8s -n kube-system get cm coredns -o jsonpath="{.data.Corefile}" | grep -q "corp.internal"'
check_sh "Corefile still contains the kubernetes plugin for cluster.local" 1 "$M"' && kc k8s -n kube-system get cm coredns -o jsonpath="{.data.Corefile}" | grep -q "kubernetes cluster.local"'
check_eventually "app.corp.internal resolves to 10.1.2.3 via the forward" 2 90 -- bash -c "kubectl --kubeconfig \"$ADMIN_KUBECONFIG\" --context k8s -n $NS exec dnsclient -- nslookup app.corp.internal | grep -q '10.1.2.3'"
check_eventually "old-db.example.org resolves to the ClusterIP of Service db" 2 90 -- bash -c "kubectl --kubeconfig \"$ADMIN_KUBECONFIG\" --context k8s -n $NS exec dnsclient -- nslookup old-db.example.org | grep -q '$DBIP'"
check_sh "cluster names still resolve (kubernetes.default)" 1 "$M"' && kc k8s -n dns-lab exec dnsclient -- nslookup kubernetes.default.svc.cluster.local'
check_sh "all CoreDNS Pods are Ready" 1 "$M"' && [ "$(kc k8s -n kube-system get deploy coredns -o jsonpath="{.status.readyReplicas}")" = "$(kc k8s -n kube-system get deploy coredns -o jsonpath="{.spec.replicas}")" ]'
