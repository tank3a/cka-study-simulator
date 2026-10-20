set -uo pipefail
source "$LIB/assert.sh"
M=/etc/kubernetes/manifests/kube-scheduler.yaml
check_node_sh "--leader-elect flag spelled correctly" 1 ek8s-cp "grep -q -- '--leader-elect=true' $M && ! grep -q -- '--leader-elct' $M"
check_node_sh "scheduler secure port matches the probe port (no custom --secure-port, or 10259)" 2 ek8s-cp "! grep -q -- '--secure-port=' $M || grep -q -- '--secure-port=10259' $M"
check_eventually "kube-scheduler pod is Ready (1/1)" 2 150 -- kc ek8s -n kube-system wait --for=condition=Ready pod/kube-scheduler-ek8s-control-plane --timeout=5s
check_eventually "sched-flag-test has 2 available replicas" 2 120 -- kc ek8s -n sched-flags wait --for=condition=Available deploy/sched-flag-test --timeout=5s
check_sh "Pods not pinned with nodeName in the template" 1 'kc ek8s -n sched-flags wait --for=condition=Available deploy/sched-flag-test --timeout=1s >/dev/null && [ -z "$(kc ek8s -n sched-flags get deploy sched-flag-test -o jsonpath="{.spec.template.spec.nodeName}")" ]'
