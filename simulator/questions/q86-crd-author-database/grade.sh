set -uo pipefail
source "$LIB/assert.sh"
T=$(mktemp -d)
export T
cat > "$T/ok.yaml" <<'YAML'
apiVersion: data.cka.example.com/v1
kind: Database
metadata: {name: grade-ok, namespace: crd-author}
spec: {engine: mysql, replicas: 2}
YAML
cat > "$T/bad-engine.yaml" <<'YAML'
apiVersion: data.cka.example.com/v1
kind: Database
metadata: {name: grade-bad1, namespace: crd-author}
spec: {engine: oracle}
YAML
cat > "$T/bad-replicas.yaml" <<'YAML'
apiVersion: data.cka.example.com/v1
kind: Database
metadata: {name: grade-bad2, namespace: crd-author}
spec: {engine: mysql, replicas: 9}
YAML
cat > "$T/no-engine.yaml" <<'YAML'
apiVersion: data.cka.example.com/v1
kind: Database
metadata: {name: grade-bad3, namespace: crd-author}
spec: {replicas: 1}
YAML
cat > "$T/default.yaml" <<'YAML'
apiVersion: data.cka.example.com/v1
kind: Database
metadata: {name: grade-def, namespace: crd-author}
spec: {engine: postgres}
YAML
C=crd/databases.data.cka.example.com
check_jsonpath "CRD names: kind Database, plural databases, short name db" 1 k8s $C '{.spec.names.kind}/{.spec.names.plural}/{.spec.names.shortNames[0]}' Database/databases/db
check_jsonpath "scope Namespaced" 1 k8s $C '{.spec.scope}' Namespaced
check_jsonpath "version v1 served and stored" 1 k8s $C '{.spec.versions[0].name}/{.spec.versions[0].served}/{.spec.versions[0].storage}' v1/true/true
check_jsonpath "status subresource enabled" 1 k8s $C '{.spec.versions[0].subresources.status}' '{}'
check_jsonpath "printer column Engine from spec.engine" 1 k8s $C '{.spec.versions[0].additionalPrinterColumns[0].name}{.spec.versions[0].additionalPrinterColumns[0].jsonPath}' Engine.spec.engine
check "valid Database accepted by the schema" 1 -- kc k8s apply --dry-run=server -f "$T/ok.yaml"
check_sh "unknown engine and replicas 9 are rejected" 2 'kc k8s apply --dry-run=server -f $T/ok.yaml >/dev/null 2>&1 && ! kc k8s apply --dry-run=server -f $T/bad-engine.yaml >/dev/null 2>&1 && ! kc k8s apply --dry-run=server -f $T/bad-replicas.yaml >/dev/null 2>&1'
check_sh "missing engine is rejected" 1 'kc k8s apply --dry-run=server -f $T/ok.yaml >/dev/null 2>&1 && ! kc k8s apply --dry-run=server -f $T/no-engine.yaml >/dev/null 2>&1'
check_eq "replicas defaults to 1" 1 "1" -- kc k8s apply --dry-run=server -f "$T/default.yaml" -o "jsonpath={.spec.replicas}"
check_sh "Database orders exists: postgres, 3 replicas" 1 '[ "$(kc k8s -n crd-author get database orders -o "jsonpath={.spec.engine}/{.spec.replicas}")" = postgres/3 ]'
