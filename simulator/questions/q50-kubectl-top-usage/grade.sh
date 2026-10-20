set -uo pipefail
source "$LIB/assert.sh"
D=/home/candidate/q50
check_file "top CPU pod is burner-a" 2 term $D/top-cpu-pod.txt '^burner-a-[a-z0-9-]+[[:space:]]*$'
check_file "top memory pod is memhog" 1 term $D/top-mem-pod.txt '^memhog-[a-z0-9-]+[[:space:]]*$'
check_file "node usage table saved" 1 term $D/nodes.txt 'k8s-worker2'
check_file "node usage table has columns" 1 term $D/nodes.txt 'CPU\(cores\)'
check_jsonpath "burner-a CPU limit is 150m" 2 k8s deploy/burner-a -n top-lab '{.spec.template.spec.containers[0].resources.limits.cpu}' 150m
