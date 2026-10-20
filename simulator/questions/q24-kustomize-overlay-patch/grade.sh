set -uo pipefail
source "$LIB/assert.sh"
NS=kz-prod
CM=$(kc k8s -n $NS get cm -o name 2>/dev/null | sed 's#.*/##' | grep '^prod-api-config-' | head -1)
check_file "overlay kustomization exists and uses the base" 1 term /home/candidate/kustomize/overlays/prod/kustomization.yaml '\.\./\.\./base'
check_sh "base left untouched" 1 'term_sh "cd /home/candidate/kustomize/base && ! grep -qE \"namePrefix|kz-prod|1\\.27|memory: 128Mi\" kustomization.yaml deployment.yaml service.yaml && grep -q \"replicas: 1\" deployment.yaml"'
check_jsonpath "replicas 3" 1 k8s deploy/prod-api -n $NS '{.spec.replicas}' 3
check_jsonpath "image nginx:1.27-alpine" 1 k8s deploy/prod-api -n $NS '{.spec.template.spec.containers[0].image}' "nginx:1.27-alpine"
check_jsonpath "env=prod label on the Deployment" 1 k8s deploy/prod-api -n $NS '{.metadata.labels.env}' prod
check_jsonpath "memory limit 128Mi" 1 k8s deploy/prod-api -n $NS '{.spec.template.spec.containers[0].resources.limits.memory}' 128Mi
check "prefixed Service exists in kz-prod" 1 -- kc k8s -n $NS get svc prod-api
check_sh "generated ConfigMap (hash suffix) has LOG_LEVEL=warn" 1 "[ -n '$CM' ] && [ \"\$(kc k8s -n $NS get cm '$CM' -o jsonpath='{.data.LOG_LEVEL}')\" = warn ]"
check_sh "Deployment envFrom references the generated ConfigMap" 1 "[ -n '$CM' ] && [ \"\$(kc k8s -n $NS get deploy prod-api -o jsonpath='{.spec.template.spec.containers[0].envFrom[0].configMapRef.name}')\" = '$CM' ]"
