set -uo pipefail
source "$LIB/assert.sh"
export U="system:serviceaccount:rbac-audit:reporter"
check_sh "answer file lists exactly the two offending bindings" 2 '[ "$(term_sh "sort /home/candidate/answers/q16-bindings.txt | tr \"\\n\" \" \"")" = "audit-legacy-view reporter-admin " ]'
check_sh "reporter-admin deleted" 1 '! kc k8s get clusterrolebinding reporter-admin >/dev/null 2>&1'
check_sh "audit-legacy-view deleted" 1 '! kc k8s get clusterrolebinding audit-legacy-view >/dev/null 2>&1'
# checks below only count once the excessive bindings are gone / the new RBAC exists (untouched state must not score)
G='! kc k8s get clusterrolebinding reporter-admin >/dev/null 2>&1'
N='kc k8s -n rbac-audit get rolebinding reporter-read >/dev/null 2>&1 && kc k8s get clusterrolebinding reporter-nodes >/dev/null 2>&1'
check_sh "other team binding untouched" 1 "$G"' && kc k8s get clusterrolebinding other-reporter-view'
check_sh "can list pods, services in rbac-audit" 1 "$N"' && [ "$(kc k8s auth can-i list pods -n rbac-audit --as=$U)" = yes ] && [ "$(kc k8s auth can-i watch services -n rbac-audit --as=$U)" = yes ]'
check_sh "can get/list nodes" 1 "$N"' && [ "$(kc k8s auth can-i list nodes --as=$U)" = yes ] && [ "$(kc k8s auth can-i get nodes --as=$U)" = yes ]'
check_sh "no pods access outside rbac-audit" 1 '[ "$(kc k8s auth can-i list pods -n default --as=$U)" = no ] && [ "$(kc k8s auth can-i list pods -n rbac-other --as=$U)" = no ]'
check_sh "no secrets read, no pod delete" 1 '[ "$(kc k8s auth can-i get secrets -n rbac-audit --as=$U)" = no ] && [ "$(kc k8s auth can-i delete pods -n rbac-audit --as=$U)" = no ]'
check_sh "bindings reporter-read/reporter-nodes use required names" 1 'kc k8s -n rbac-audit get role reporter-read && kc k8s -n rbac-audit get rolebinding reporter-read && kc k8s get clusterrole reporter-nodes && kc k8s get clusterrolebinding reporter-nodes'
check_sh "rbac-other reporter keeps its view access" 1 "$G"' && [ "$(kc k8s auth can-i list pods -n rbac-other --as=system:serviceaccount:rbac-other:reporter)" = yes ]'
