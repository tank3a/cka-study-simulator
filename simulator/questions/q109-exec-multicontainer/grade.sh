set -uo pipefail
source "$LIB/assert.sh"
D=/home/candidate/q109
check_file "region.txt has the app container region" 1 term $D/region.txt '^eu-north-1[[:space:]]*$'
check_file "denied-count.txt has the number 3" 2 term $D/denied-count.txt '^3[[:space:]]*$'
check_file "title.txt has the nginx page title" 1 term $D/title.txt '^Welcome to nginx!?[[:space:]]*$'
check "/tmp/inspected exists in container app" 1 -- kc k8s -n exec-lab exec orders -c app -- test -f /tmp/inspected
check_sh "Pod was not restarted or recreated (restartCount 0 for both containers)" 1 '[ "$(kc k8s -n exec-lab get pod orders -o jsonpath="{.status.containerStatuses[*].restartCount}")" = "0 0" ]'
