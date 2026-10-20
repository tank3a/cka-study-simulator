# q52 해설: rollout history 에서 특정 revision 으로 롤백

문서:
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ (`Ctrl+F` `Rolling Back to a Previous Revision`)
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_rollout/

## 진단
`kubectl rollout undo` 만 쓰면 바로 이전 revision(v3-experimental) 으로 간다. 목표는 change-cause 가 `v2-stable` 인 revision 이므로
history 로 번호를 찾고 `--to-revision` 으로 지정해야 한다. (revision 번호는 보통 2 이지만 환경에서 확인할 것.)

## 풀이
```bash
kubectl config use-context k8s
kubectl -n rollout2 rollout history deploy/shop | tee /home/candidate/history-before.txt
# CHANGE-CAUSE 가 v2-stable 인 REVISION 번호 확인 (예: 2). 이미지 확인:
kubectl -n rollout2 rollout history deploy/shop --revision=2
kubectl -n rollout2 rollout undo deploy/shop --to-revision=2
kubectl -n rollout2 annotate deploy/shop kubernetes.io/change-cause="rollback to v2-stable" --overwrite
kubectl -n rollout2 rollout status deploy/shop
```

## 검증
```bash
kubectl -n rollout2 get deploy shop -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl -n rollout2 rollout history deploy/shop
```

## 흔한 실수
- history 파일을 롤백 후에 저장 (그러면 v4-broken 이 최신 revision 으로 보이지 않는다).
- `rollout undo` 로 바로 이전(v3) 으로 롤백.
- change-cause 를 롤백 전에 설정 (undo 시 annotation 이 해당 revision 의 값으로 되돌아온다).
