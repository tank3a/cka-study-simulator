set -uo pipefail
source "$LIB/assert.sh"
D=/home/candidate/q110
check_file "v2-version.txt has the report-v2 build" 2 term $D/v2-version.txt '^build-4471[[:space:]]*$'
check_sh "v2-version.txt does not contain the v1 build" 1 'term_sh "test -s /home/candidate/q110/v2-version.txt" && ! term_sh "grep -q build-3302 /home/candidate/q110/v2-version.txt"'
check_file "license.txt has the LICENSE_TIER value" 2 term $D/license.txt '^gold-7731[[:space:]]*$'
check_sh "Pod sealed has an ephemeral container using busybox that targets app" 1 'kc k8s -n pf-lab get pod sealed -o jsonpath="{.spec.ephemeralContainers[*].image}/{.spec.ephemeralContainers[*].targetContainerName}" | grep -q "busybox.*/app"'
check_sh "sealed container app was not restarted and Pods untouched" 1 '[ "$(kc k8s -n pf-lab get pod sealed -o jsonpath="{.status.containerStatuses[0].restartCount}")" = "0" ] && [ "$(kc k8s -n pf-lab get svc report -o jsonpath="{.spec.selector.track}")" = "v1" ] && ! kc k8s -n pf-lab get pod sealed-debug >/dev/null 2>&1'
