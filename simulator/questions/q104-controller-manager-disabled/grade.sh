set -uo pipefail
source "$LIB/assert.sh"
M=/etc/kubernetes/manifests/kube-controller-manager.yaml
check_node_sh "no --controllers flag disabling replicaset/job remains" 2 ek8s-cp "! grep -qE -- '--controllers=.*-(replicaset|job)' $M"
check_node_sh "kube-controller-manager command still has its standard flags" 1 ek8s-cp "! grep -qE -- '--controllers=.*-(replicaset|job)' $M && grep -q -- '--use-service-account-credentials=true' $M && grep -q -- '--leader-elect=true' $M"
cm_fixed_ready() { on_node ek8s-cp bash -c "! grep -qE -- '--controllers=.*-(replicaset|job)' $M" && kc ek8s -n kube-system wait --for=condition=Ready pod/kube-controller-manager-ek8s-control-plane --timeout=5s; }
check_eventually "kube-controller-manager pod is Ready (flag fixed)" 2 120 -- cm_fixed_ready
check_eventually "rs-test has 2 available replicas" 2 120 -- kc ek8s -n cm-off wait --for=condition=Available deploy/rs-test --timeout=5s
check_eventually "Job batch-test completed" 2 120 -- kc ek8s -n cm-off wait --for=condition=Complete job/batch-test --timeout=5s
check_sh "Job and Deployment were not recreated by hand (no bare pods)" 1 'kc ek8s -n cm-off wait --for=condition=Available deploy/rs-test --timeout=1s >/dev/null && [ -z "$(kc ek8s -n cm-off get pods -o jsonpath="{range .items[?(@.metadata.ownerReferences==null)]}{.metadata.name}{end}")" ]'
