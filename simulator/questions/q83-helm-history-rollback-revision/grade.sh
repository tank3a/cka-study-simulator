set -uo pipefail
source "$LIB/assert.sh"
H="helm --kubeconfig $ADMIN_KUBECONFIG --kube-context k8s"
export H
check_file "first revision with 1.27-alpine is 2" 1 term /home/candidate/answers/q83-revision.txt '^2$'
check_sh "latest revision is deployed and is a rollback to 2" 2 '$H -n helm-ledger history ledger | tail -1 | grep -q deployed && $H -n helm-ledger history ledger | tail -1 | grep -q "Rollback to 2"'
check_sh "history was kept (4 revisions, not re-installed)" 1 '[ "$($H -n helm-ledger history ledger | tail -n +2 | wc -l | tr -d " ")" = 4 ]'
check_match "deployment runs image 1.27-alpine" 1 'nginx:1\.27-alpine' -- kc k8s -n helm-ledger get deploy ledger -o "jsonpath={.spec.template.spec.containers[0].image}"
check_file "saved values contain the rolled-back tag" 1 term /home/candidate/answers/q83-values.yaml '1\.27-alpine'
check_eventually "ledger pods are Running" 1 90 -- bash -c 'helm --kubeconfig "$ADMIN_KUBECONFIG" --kube-context k8s -n helm-ledger history ledger | tail -1 | grep -q "Rollback to" && [ "$(kubectl --kubeconfig "$ADMIN_KUBECONFIG" --context k8s -n helm-ledger get deploy ledger -o "jsonpath={.status.availableReplicas}")" = 1 ]'
