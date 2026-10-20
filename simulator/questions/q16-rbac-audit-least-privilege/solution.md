# q16 풀이

```bash
kubectl config use-context k8s
# 1) 이름이 같은 SA(rbac-other)와 구분해서 namespace까지 확인
kubectl get clusterrolebinding -o json | jq -r \
 '.items[] | select(.subjects[]? | .kind=="ServiceAccount" and .name=="reporter" and .namespace=="rbac-audit") | .metadata.name' \
 | sort > ~/answers/q16-bindings.txt
cat ~/answers/q16-bindings.txt      # audit-legacy-view, reporter-admin (other-reporter-view는 제외)

# 2) 삭제
kubectl delete clusterrolebinding reporter-admin audit-legacy-view

# 3) 최소 권한
kubectl -n rbac-audit create role reporter-read --verb=get,list,watch --resource=pods,services
kubectl -n rbac-audit create rolebinding reporter-read --role=reporter-read --serviceaccount=rbac-audit:reporter
kubectl create clusterrole reporter-nodes --verb=get,list --resource=nodes
kubectl create clusterrolebinding reporter-nodes --clusterrole=reporter-nodes --serviceaccount=rbac-audit:reporter

# 검증
kubectl auth can-i list pods -n rbac-audit --as=system:serviceaccount:rbac-audit:reporter
kubectl auth can-i get secrets -n rbac-audit --as=system:serviceaccount:rbac-audit:reporter
```

함정: 같은 이름의 SA가 다른 namespace에도 있으니 jq에서 `.namespace`까지 비교. 노드는 cluster-scoped라 Role이 아니라 ClusterRole+ClusterRoleBinding이 필요.

문서: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
