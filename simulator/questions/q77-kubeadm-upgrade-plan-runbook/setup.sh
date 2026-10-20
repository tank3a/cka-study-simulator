set -uo pipefail
source "$LIB/common.sh"
kc ek8s uncordon ek8s-worker >/dev/null 2>&1 || true
node_sh ek8s-cp 'mkdir -p /opt/cka; rm -f /opt/cka/upgrade-plan.txt /opt/cka/drain-dryrun.txt /opt/cka/upgrade-runbook.txt'
