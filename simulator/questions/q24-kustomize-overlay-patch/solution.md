# q24 풀이

```bash
kubectl config use-context k8s
cd ~/kustomize/overlays/prod
cat > kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namespace: kz-prod
namePrefix: prod-
labels:
  - pairs:
      env: prod
    includeSelectors: true
replicas:
  - name: api
    count: 3
images:
  - name: nginx
    newTag: 1.27-alpine
configMapGenerator:
  - name: api-config
    literals:
      - LOG_LEVEL=warn
patches:
  - target:
      kind: Deployment
      name: api
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/resources/limits/memory
        value: 128Mi
YAML
kubectl kustomize .            # 미리보기: prefix, hash suffix, envFrom 이름 자동 치환 확인
kubectl apply -k .
kubectl -n kz-prod get deploy,svc,cm
```

핵심: `namePrefix` 때문에 이름 참조(`envFrom`)는 Kustomize가 generator 결과(`prod-api-config-<hash>`)로 자동 치환한다. `replicas:`/`images:`는 이름 기준(원본 이름 `api`, `nginx`)으로 쓴다. `commonLabels` 대신 `labels`를 권장(commonLabels는 deprecated).

문서: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
