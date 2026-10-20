# q07 해설: Rollback + RollingUpdate 전략 + change-cause

문서: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ (`Ctrl+F` `Rolling Back a Deployment`, `Updating a Deployment`, `maxSurge`)

## 1) 롤백
```bash
kubectl config use-context k8s
kubectl -n rollout-demo rollout history deploy/web
kubectl -n rollout-demo rollout undo deploy/web            # 직전 revision 으로. 특정 revision: --to-revision=1
kubectl -n rollout-demo rollout status deploy/web
```
`undo` 는 새 revision 번호(3)를 만들고 이전 revision(1) 항목은 history 에서 사라진다.

## 2) 전략 변경
```bash
kubectl -n rollout-demo patch deploy web -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":2,"maxUnavailable":0}}}}'
```
(또는 `kubectl edit deploy web`)

## 3) 이미지 업데이트 + change-cause
`--record` 플래그는 deprecated 이므로 annotation 을 직접 단다. annotation 은 **업데이트 전에** 달아야 새 revision 에 기록된다.
```bash
kubectl -n rollout-demo annotate deploy/web kubernetes.io/change-cause="upgrade to alpine" --overwrite
kubectl -n rollout-demo set image deploy/web nginx=nginx:1.27-alpine
kubectl -n rollout-demo rollout status deploy/web
```
컨테이너 이름은 `kubectl -n rollout-demo get deploy web -o jsonpath='{.spec.template.spec.containers[*].name}'` 로 확인 (`nginx`).

## 4) history 저장
```bash
kubectl -n rollout-demo rollout history deploy/web > /home/candidate/web-history.txt
cat /home/candidate/web-history.txt
```

## 흔한 실수
- 문제 지시는 "업데이트 전에 annotate"입니다. 순서를 바꾸면 history 의 CHANGE-CAUSE 가 `<none>`이 될 수 있습니다(v1.34 클러스터에서는 set image 뒤에 annotate 해도 기록되는 것이 관찰됨, 버전에 따라 다를 수 있으니 문제 지시 순서를 지키세요). 반대로 annotate 를 먼저 하면 직전 revision 의 CHANGE-CAUSE 까지 같은 값으로 덮어써질 수 있습니다.
- 롤백 없이 바로 새 이미지로 업데이트 (롤백 단계 누락 -> 감점).
- `maxSurge=2, maxUnavailable=0` 에서 둘 다 0 으로 쓰면 에러 (둘 다 0 은 불가).
- 컨테이너 이름을 몰라 `set image` 가 실패 (`*=nginx:1.27-alpine` 로 모두 변경도 가능).
