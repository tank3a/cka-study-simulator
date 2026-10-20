set -uo pipefail
source "$LIB/assert.sh"
CONF=$(kc k8s -n kube-system get cm kube-proxy -o jsonpath='{.data.config\.conf}' 2>/dev/null)
MODE=$(printf '%s\n' "$CONF" | grep -E '^[[:space:]]*mode:' | head -1 | sed 's/.*mode:[[:space:]]*//; s/"//g; s/[[:space:]]*$//')
[ -z "$MODE" ] && MODE=iptables
CIDR=$(printf '%s\n' "$CONF" | grep -E '^[[:space:]]*clusterCIDR:' | head -1 | sed 's/.*clusterCIDR:[[:space:]]*//; s/"//g; s/[[:space:]]*$//')
CHAIN=$(on_node k8s-worker iptables-save -t nat 2>/dev/null | grep 'kp-lab/echo:http cluster IP' | grep -o 'KUBE-SVC-[A-Z0-9]*' | head -1)
check_file "file exists with 3 lines" 1 term /home/candidate/kube-proxy.txt '^mode='
check_sh "mode line is correct" 2 'term_sh "grep -E \"^mode=\" /home/candidate/kube-proxy.txt" | tr -d " \r" | grep -qx "mode='"$MODE"'"'
check_sh "cluster-cidr line is correct" 2 '[ -n "'"$CIDR"'" ] && term_sh "grep -E \"^cluster-cidr=\" /home/candidate/kube-proxy.txt" | tr -d " \r" | grep -qx "cluster-cidr='"$CIDR"'"'
check_sh "chain line names the KUBE-SVC chain of kp-lab/echo" 3 '[ -n "'"$CHAIN"'" ] && term_sh "grep -E \"^chain=\" /home/candidate/kube-proxy.txt" | tr -d " \r" | grep -qx "chain='"$CHAIN"'"'
check_sh "kube-proxy ConfigMap in kube-system untouched (still has config.conf)" 1 'kc k8s -n kube-system get cm kube-proxy -o jsonpath="{.data.config\.conf}" | grep -q "kind: KubeProxyConfiguration"'
