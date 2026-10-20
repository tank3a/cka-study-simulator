set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-cp
check_file "upgrade plan output saved" 1 $N /opt/cka/upgrade-plan.txt 'upgrade'
check_file "drain dry-run output saved" 1 $N /opt/cka/drain-dryrun.txt 'ek8s-worker.*dry run'
check_sh "worker still schedulable" 1 'node_sh ek8s-cp "test -s /opt/cka/drain-dryrun.txt" && [ -z "$(kc ek8s get node ek8s-worker -o "jsonpath={.spec.unschedulable}")" ]'
check_sh "runbook has the steps in the right order" 3 'F=/opt/cka/upgrade-runbook.txt; p=0; for pat in "drain" "install.*kubeadm" "kubeadm upgrade node" "install.*kubelet" "systemctl restart kubelet" "uncordon"; do n=$(node_sh ek8s-cp "grep -nE \"$pat\" $F | head -1 | cut -d: -f1"); [ -n "$n" ] && [ "$n" -gt "$p" ] || exit 1; p=$n; done'
