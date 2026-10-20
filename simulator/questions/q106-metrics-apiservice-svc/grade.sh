set -uo pipefail
source "$LIB/assert.sh"
D=/home/candidate/q106
# the APIService condition can be stale (True) for a while after the fault is injected: count it only once the Service is fixed
svc_fixed() { t=$(kc k8s -n kube-system get svc metrics-server -o jsonpath="{.spec.ports[0].targetPort}"); [ "$t" = "https" ] || [ "$t" = "10250" ]; }
api_av() { svc_fixed && kc k8s wait --for=condition=Available apiservice/v1beta1.metrics.k8s.io --timeout=5s; }
check_eventually "APIService v1beta1.metrics.k8s.io is Available" 2 90 -- api_av
check_eventually "kubectl top nodes works" 1 60 -- kc k8s top nodes --no-headers
check_sh "Service metrics-server targets the container port (10250 or name https)" 2 't=$(kc k8s -n kube-system get svc metrics-server -o jsonpath="{.spec.ports[0].targetPort}"); [ "$t" = "https" ] || [ "$t" = "10250" ]'
check_sh "APIService still points at kube-system/metrics-server" 1 't=$(kc k8s -n kube-system get svc metrics-server -o jsonpath="{.spec.ports[0].targetPort}"); { [ "$t" = "https" ] || [ "$t" = "10250" ]; } && [ "$(kc k8s get apiservice v1beta1.metrics.k8s.io -o jsonpath="{.spec.service.namespace}/{.spec.service.name}")" = "kube-system/metrics-server" ]'
check_file "cause.txt names service/metrics-server" 1 term $D/cause.txt '^service/metrics-server[[:space:]]*$'
check_file "pods-top.txt lists containers with metrics" 1 term $D/pods-top.txt 'coredns'
