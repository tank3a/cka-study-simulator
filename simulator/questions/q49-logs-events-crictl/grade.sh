set -uo pipefail
source "$LIB/assert.sh"
D=/home/candidate/q49
check_file "shipper log saved with shipper output" 1 term $D/shipper.log 'shipping batch'
check_sh "shipper log has no collector lines" 1 'term_sh "test -s /home/candidate/q49/shipper.log" && ! term_sh "grep -q \"collector heartbeat\" /home/candidate/q49/shipper.log"'
check_file "crasher previous log saved" 1 term $D/crasher-previous.log 'fatal: license key missing'
check_file "warning events saved (BackOff of crasher)" 1 term $D/warnings.txt 'BackOff'
check_sh "warnings file has only Warning events" 1 'term_sh "test -s /home/candidate/q49/warnings.txt" && ! term_sh "grep -Eq \"[[:space:]]Normal[[:space:]]\" /home/candidate/q49/warnings.txt"'
check_file "top output lists both containers" 1 term $D/top.txt 'shipper'
check_node_sh "crictl full container ID of shipper written" 2 k8s-node1 'id=$(tr -d "[:space:]" < /opt/cka/q49-shipper-id.txt); [ ${#id} -ge 12 ] && crictl ps --no-trunc -q --name "^shipper$" | grep -q "^$id"'
