set -uo pipefail
source "$LIB/common.sh"
ns_create k8s rbac-audit
ns_create k8s rbac-other
kapply k8s -f - <<YAML
apiVersion: v1
kind: ServiceAccount
metadata: {name: reporter, namespace: rbac-audit, labels: {exam.q: "$QID"}}
---
apiVersion: v1
kind: ServiceAccount
metadata: {name: reporter, namespace: rbac-other, labels: {exam.q: "$QID"}}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata: {name: reporter-admin, labels: {exam.q: "$QID"}}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: ClusterRole, name: cluster-admin}
subjects:
  - {kind: ServiceAccount, name: reporter, namespace: rbac-audit}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata: {name: audit-legacy-view, labels: {exam.q: "$QID"}}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: ClusterRole, name: view}
subjects:
  - {kind: ServiceAccount, name: other-sa, namespace: default}
  - {kind: ServiceAccount, name: reporter, namespace: rbac-audit}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata: {name: other-reporter-view, labels: {exam.q: "$QID"}}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: ClusterRole, name: view}
subjects:
  - {kind: ServiceAccount, name: reporter, namespace: rbac-other}
YAML
term_sh 'mkdir -p /home/candidate/answers && rm -f /home/candidate/answers/q16-bindings.txt'
