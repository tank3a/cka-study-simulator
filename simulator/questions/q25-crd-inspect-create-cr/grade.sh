set -uo pipefail
source "$LIB/assert.sh"
A=/home/candidate/answers
COUNT=$(kc k8s get backups.ops.cka.example.com -A --no-headers 2>/dev/null | grep -c .)
check_sh "CRD list is exactly the two ops.cka.example.com CRDs" 2 '[ "$(term_sh "grep -v \"^\$\" '$A'/q25-crds.txt | tr \"\\n\" \" \"")" = "backups.ops.cka.example.com restores.ops.cka.example.com " ]'
check_file "explain output saved" 1 term $A/q25-explain.txt 'number of days a result is kept'
check_file "explain output is for retentionDays" 1 term $A/q25-explain.txt 'retentionDays'
check_jsonpath "Backup nightly schedule" 1 k8s backups.ops.cka.example.com/nightly -n crd-demo '{.spec.schedule}' "0 2 * * *"
check_jsonpath "Backup nightly target" 1 k8s backups.ops.cka.example.com/nightly -n crd-demo '{.spec.target}' "pvc/data"
check_jsonpath "Backup nightly retentionDays" 1 k8s backups.ops.cka.example.com/nightly -n crd-demo '{.spec.retentionDays}' 14
check_file "count file matches current number of Backups ($COUNT)" 1 term $A/q25-count.txt "^[[:space:]]*${COUNT}[[:space:]]*\$"
