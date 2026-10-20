set -uo pipefail
source "$LIB/assert.sh"
A=/home/candidate/answers/q85.txt
check_file "scope" 1 term $A '^scope=Namespaced$'
check_file "storage version" 1 term $A '^storage_version=v1$'
check_file "served versions" 1 term $A '^served_versions=v1,v1alpha1$'
check_file "short name" 1 term $A '^short_name=wg$'
check_file "required fields" 1 term $A '^required_fields=size$'
check_file "red widgets in all namespaces" 2 term $A '^red_widgets=widget-lab/w1,widget-lab/w3,widget-other/w4$'
check_sh "w5 is green/M" 1 '[ "$(kc k8s -n widget-lab get widgets.v1.shop.cka.example.com w5 -o "jsonpath={.spec.color}/{.spec.size}")" = green/M ]'
check_sh "w6 was fixed: green/L" 2 '[ "$(kc k8s -n widget-lab get widgets.v1.shop.cka.example.com w6 -o "jsonpath={.spec.color}/{.spec.size}")" = green/L ]'
check_sh "CRD untouched (both versions still served)" 1 'kc k8s -n widget-lab get widgets.v1.shop.cka.example.com w5 >/dev/null 2>&1 && [ "$(kc k8s get crd widgets.shop.cka.example.com -o "jsonpath={.spec.versions[*].name}")" = "v1alpha1 v1" ]'
