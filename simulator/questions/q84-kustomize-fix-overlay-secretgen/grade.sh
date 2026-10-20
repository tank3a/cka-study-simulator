set -uo pipefail
source "$LIB/assert.sh"
K=/home/candidate/kz2/overlays/dev/kustomization.yaml
check_sh "overlay builds" 2 'term_sh "kubectl kustomize /home/candidate/kz2/overlays/dev >/dev/null 2>&1"'
check_sh "no deprecated fields (bases, patchesStrategicMerge)" 1 '! term_sh "grep -Eq \"^(bases|patchesStrategicMerge):\" /home/candidate/kz2/overlays/dev/kustomization.yaml"'
check_sh "overlay build emits no warning" 1 '[ -z "$(term_sh "kubectl kustomize /home/candidate/kz2/overlays/dev 2>&1 >/dev/null")" ]'
check_jsonpath "dev-web has 3 replicas (patch applied)" 1 k8s deploy/dev-web -n kz-dev '{.spec.replicas}' 3
check_sh "Secret dev-db-creds exists without hash suffix and holds the password" 2 '[ "$(kc k8s -n kz-dev get secret dev-db-creds -o "jsonpath={.data.password}" | base64 -d)" = s3cr3t ]'
check_jsonpath "Deployment references dev-db-creds" 1 k8s deploy/dev-web -n kz-dev '{.spec.template.spec.containers[0].env[0].valueFrom.secretKeyRef.name}' dev-db-creds
check_sh "base untouched" 1 'term_sh "kubectl kustomize /home/candidate/kz2/overlays/dev >/dev/null 2>&1" && term_sh "grep -q \"replicas: 1\" /home/candidate/kz2/base/deployment.yaml && grep -q \"name: db-creds\" /home/candidate/kz2/base/deployment.yaml"'
