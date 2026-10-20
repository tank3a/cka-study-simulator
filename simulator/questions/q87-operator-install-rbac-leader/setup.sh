set -uo pipefail
source "$LIB/common.sh"
kc k8s delete clusterrolebinding sync-operator --ignore-not-found >/dev/null 2>&1
kc k8s delete clusterrole sync-operator --ignore-not-found >/dev/null 2>&1
kc k8s delete crd syncjobs.sync.cka.example.com --ignore-not-found >/dev/null 2>&1
kc k8s delete ns ops-system --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1
term_sh 'mkdir -p /home/candidate/operator'
term_put /home/candidate/operator/bundle.yaml <<'YAML'
apiVersion: v1
kind: Namespace
metadata:
  name: ops-system
  labels: {exam.q: q87-operator-install-rbac-leader}
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: syncjobs.sync.cka.example.com
  labels: {exam.q: q87-operator-install-rbac-leader}
spec:
  group: sync.cka.example.com
  scope: Namespaced
  names: {plural: syncjobs, singular: syncjob, kind: SyncJob}
  versions:
    - name: v1
      served: true
      storage: true
      subresources: {status: {}}
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required: [source, dest]
              properties:
                source: {type: string}
                dest: {type: string}
            status:
              type: object
              x-kubernetes-preserve-unknown-fields: true
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sync-operator
  namespace: ops-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sync-operator
  namespace: ops-system
spec:
  replicas: 0
  selector:
    matchLabels: {app: sync-operator}
  template:
    metadata:
      labels: {app: sync-operator}
    spec:
      serviceAccountName: sync-operator
      containers:
        - name: manager
          image: nginx:1.27
YAML
