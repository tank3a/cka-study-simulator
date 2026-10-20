# q69 풀이

```bash
kubectl config use-context k8s

# 1) 그룹에 클러스터 전체 namespace 조회 권한
kubectl create clusterrole ns-lister --verb=get,list,watch --resource=namespaces
kubectl create clusterrolebinding ns-lister --clusterrole=ns-lister --group=ops-audit

# 2) ClusterRole을 만들고 RoleBinding으로 한 namespace에만 부여
kubectl create clusterrole cm-editor --verb=get,list,watch,update,patch --resource=configmaps
kubectl -n cr-a create rolebinding cm-editor --clusterrole=cm-editor --serviceaccount=cr-a:deployer

# 3) non-resource URL
kubectl create clusterrole metrics-reader --verb=get --non-resource-url=/metrics
kubectl create clusterrolebinding metrics-reader --clusterrole=metrics-reader --user=monitor

# 검증
kubectl auth can-i list namespaces --as=u1 --as-group=ops-audit
kubectl auth can-i update configmaps -n cr-b --as=system:serviceaccount:cr-a:deployer   # no
kubectl auth can-i get /metrics --as=monitor
```

핵심: ClusterRole + RoleBinding 조합은 "권한 정의는 재사용, 적용 범위는 namespace 하나"로 제한한다. `/metrics` 같은 non-resource URL은 Role이 아니라 ClusterRole의 `nonResourceURLs`로만 줄 수 있다.

문서: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
