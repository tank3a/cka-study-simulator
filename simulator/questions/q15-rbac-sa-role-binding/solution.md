# q15 풀이

```bash
kubectl config use-context k8s
kubectl -n rbac-dev create sa ci-deployer
kubectl -n rbac-dev create role deploy-manager \
  --verb=get,list,watch,create,update,patch --resource=deployments.apps
# 두 번째 규칙은 imperative로 한 번에 못 만든다: 하나 더 만들어 합치거나 YAML을 편집
kubectl -n rbac-dev edit role deploy-manager     # rules 추가: pods get,list / pods/log get
kubectl -n rbac-dev create rolebinding ci-deployer-binding --role=deploy-manager --serviceaccount=rbac-dev:ci-deployer
kubectl -n rbac-dev set serviceaccount deploy/pipeline ci-deployer
mkdir -p ~/answers
kubectl auth can-i delete deployments -n rbac-dev --as=system:serviceaccount:rbac-dev:ci-deployer > ~/answers/q15-delete.txt
```

추가될 rules:
```yaml
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
```

주의: `--serviceaccount`는 `namespace:name` 형식. `can-i`의 `--as`는 `system:serviceaccount:<ns>:<name>`.

문서: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
