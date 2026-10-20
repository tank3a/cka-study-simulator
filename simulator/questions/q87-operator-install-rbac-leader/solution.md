# q87 풀이

```bash
kubectl config use-context k8s
# 1) 번들 설치 (Namespace가 먼저 오므로 한 번에 적용 가능)
kubectl apply -f ~/operator/bundle.yaml
kubectl get crd syncjobs.sync.cka.example.com

# 2) RBAC: 규칙이 둘 이상이므로 YAML이 편하다 (아래 블록)
```

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata: {name: sync-operator}
rules:
- apiGroups: [sync.cka.example.com]
  resources: [syncjobs, syncjobs/status, syncjobs/finalizers]
  verbs: [get, list, watch, update, patch]
- apiGroups: [""]
  resources: [events]
  verbs: [create, patch]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata: {name: sync-operator}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: ClusterRole, name: sync-operator}
subjects: [{kind: ServiceAccount, name: sync-operator, namespace: ops-system}]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: {name: leader-election, namespace: ops-system}
rules:
- apiGroups: [coordination.k8s.io]
  resources: [leases]
  verbs: [get, list, watch, create, update, patch]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata: {name: leader-election, namespace: ops-system}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: Role, name: leader-election}
subjects: [{kind: ServiceAccount, name: sync-operator, namespace: ops-system}]
EOF
```

```bash
# 3) 시작
kubectl -n ops-system scale deploy sync-operator --replicas=1
kubectl -n ops-system rollout status deploy sync-operator

# 4) CR 생성
cat <<'EOF' | kubectl apply -f -
apiVersion: sync.cka.example.com/v1
kind: SyncJob
metadata: {name: nightly, namespace: ops-system}
spec: {source: "s3://src", dest: "s3://dst"}
EOF

# 검증
kubectl auth can-i patch syncjobs.sync.cka.example.com --subresource=status -n default --as=system:serviceaccount:ops-system:sync-operator
```

핵심: 오퍼레이터 = CRD + 컨트롤러(Deployment) + 그 컨트롤러가 쓸 RBAC. 리소스 CR 권한은 cluster 범위, leader election용 `leases`는 자기 namespace의 Role로 충분하다. `/status`, `/finalizers`는 별도 서브리소스라 따로 허용해야 한다. 이 랩의 Deployment는 nginx 대체물이라 실제 reconcile은 일어나지 않는다 (fidelity: partial).

문서: https://kubernetes.io/docs/concepts/extend-kubernetes/operator/
      https://kubernetes.io/docs/reference/access-authn-authz/rbac/
