set -uo pipefail
source "$LIB/assert.sh"
D=/home/candidate/q105
check_eventually "APIService v1beta1.metrics.k8s.io is Available" 2 120 -- kc k8s wait --for=condition=Available apiservice/v1beta1.metrics.k8s.io --timeout=5s
check_eventually "kubectl top nodes works" 1 60 -- kc k8s top nodes --no-headers
check_sh "metrics-server args contain --kubelet-insecure-tls" 2 'kc k8s -n kube-system get deploy metrics-server -o jsonpath="{.spec.template.spec.containers[0].args}" | grep -q kubelet-insecure-tls'
check_file "cause.txt names the missing flag" 1 term $D/cause.txt 'kubelet-insecure-tls'
check_file "nodes.txt has header and the worker node" 1 term $D/nodes.txt 'CPU\(cores\)'
check_file "nodes.txt lists k8s-worker2" 1 term $D/nodes.txt 'k8s-worker2'
