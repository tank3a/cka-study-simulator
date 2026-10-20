set -uo pipefail
source "$LIB/assert.sh"
export F=/home/candidate/kc/ravi.kubeconfig
check_file "kubeconfig exists" 1 term $F
check_sh "current-context is ravi@kcfg" 1 '[ "$(term_sh "kubectl --kubeconfig $F config current-context")" = "ravi@kcfg" ]'
check_sh "cluster is named kcfg-cluster" 1 'term_sh "kubectl --kubeconfig $F config get-clusters" | grep -qx kcfg-cluster'
check_sh "CA, certificate and key are embedded" 2 'term_sh "grep -q certificate-authority-data $F && grep -q client-certificate-data $F && grep -q client-key-data $F"'
check_sh "no external file paths inside" 1 'term_sh "grep -q client-key-data $F" && ! term_sh "grep -Eq \"^ *(certificate-authority|client-certificate|client-key):\" $F"'
check_sh "default namespace kcfg in the context" 1 'term_sh "grep -Eq \"namespace: kcfg\" $F"'
check_sh "ravi can list pods in kcfg through this file" 1 '[ "$(term_sh "kubectl --kubeconfig $F auth can-i list pods -n kcfg")" = yes ]'
check_sh "file authenticates as ravi (cannot delete pods)" 1 '[ "$(term_sh "kubectl --kubeconfig $F auth can-i delete pods -n kcfg")" = no ]'
check_sh "contexts answer matches default kubeconfig" 1 '[ -n "$(term_sh "sort /home/candidate/answers/q71-contexts.txt")" ] && [ "$(term_sh "sort /home/candidate/answers/q71-contexts.txt")" = "$(term_sh "kubectl config get-contexts -o name | sort")" ]'
check_sh "default kubeconfig untouched" 1 'term_sh "test -s $F" && ! term_sh "grep -q ravi /home/candidate/.kube/config"'
