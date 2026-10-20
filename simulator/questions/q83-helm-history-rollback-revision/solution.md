# q83 풀이

```bash
kubectl config use-context k8s
helm -n helm-ledger history ledger
# REVISION  STATUS      DESCRIPTION
# 1         superseded  Install complete
# 2         superseded  Upgrade complete
# 3         deployed    Upgrade complete       <- 깨진 이미지

# 어느 revision이 어떤 태그였는지 확인
for r in 1 2 3; do echo "rev $r:"; helm -n helm-ledger get values ledger --revision $r; done
echo 2 > ~/answers/q83-revision.txt

helm -n helm-ledger rollback ledger 2          # 새 revision 4가 만들어진다 (description: Rollback to 2)
helm -n helm-ledger history ledger
helm -n helm-ledger get values ledger -o yaml > ~/answers/q83-values.yaml
kubectl -n helm-ledger get pods
```

함정: `helm rollback ledger`(번호 없음)는 직전 revision(3, 이것도 깨짐)이 아니라 바로 이전 revision으로 돌아간다. 번호를 명시한다. 롤백은 history를 지우지 않고 새 revision을 추가한다. `helm get values`는 사용자가 준 값만, `-a`를 붙이면 계산된 전체 값을 보여준다.

문서: https://helm.sh/docs/intro/using_helm/
