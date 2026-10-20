# q23 풀이

```bash
kubectl config use-context k8s
helm -n helm-app history shop               # rev1 deployed(ok) -> rev2 failed/깨진 이미지
helm -n helm-app rollback shop 1            # rev3 = Rollback to 1
helm -n helm-app get values shop            # 현재 사용자 값 확인 (replicaCount, message)
helm -n helm-app upgrade shop ~/helm/cka-app --reuse-values --set replicaCount=3
kubectl -n helm-app get pods

# 렌더링만 (설치 없음): -n 은 .Release.Namespace 에 반영
helm template preview ~/helm/cka-app -n helm-app -f ~/helm/preview-values.yaml > ~/answers/preview.yaml
```

핵심:
- `rollback` 도 새 revision을 만든다(rev3). 이후 upgrade는 rev4.
- `--reuse-values`를 쓰지 않으면 이전 `--set` 값(message=prod)이 차트 기본값(hello)으로 돌아간다. 대안: `--reset-then-reuse-values`.
- `helm template`은 클러스터에 아무것도 만들지 않는다. 릴리스 이름이 `preview`이므로 리소스 이름은 `preview-cka-app`.

문서: https://helm.sh/docs/intro/using_helm/
