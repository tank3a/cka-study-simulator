set -uo pipefail
source "$LIB/assert.sh"
M=/etc/kubernetes/manifests/kube-scheduler.yaml
check_node_sh "scheduler image tag equals the apiserver image tag" 2 ek8s-cp "a=\$(awk '/image:/{print \$2; exit}' /etc/kubernetes/manifests/kube-apiserver.yaml); s=\$(awk '/image:/{print \$2; exit}' $M); [ \"\${a##*:}\" = \"\${s##*:}\" ]"
check_node_sh "scheduler --kubeconfig points to an existing file" 1 ek8s-cp "f=\$(sed -n 's/.*- --kubeconfig=//p' $M); [ -n \"\$f\" ] && [ -f \"\$f\" ]"
check_eventually "kube-scheduler pod is Ready" 2 120 -- kc ek8s -n kube-system wait --for=condition=Ready pod/kube-scheduler-ek8s-control-plane --timeout=5s
check_eventually "sched-test has 2 available replicas" 2 90 -- kc ek8s -n sched-fix wait --for=condition=Available deploy/sched-test --timeout=5s
check_sh "sched-test pods were not pinned with nodeName" 1 '[ "$(kc ek8s -n sched-fix get deploy sched-test -o jsonpath="{.status.availableReplicas}")" -ge 1 ] 2>/dev/null && [ -z "$(kc ek8s -n sched-fix get deploy sched-test -o jsonpath="{.spec.template.spec.nodeName}")" ]'
