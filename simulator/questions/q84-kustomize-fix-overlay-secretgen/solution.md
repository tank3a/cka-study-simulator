# q84 풀이

```bash
kubectl config use-context k8s
cd ~/kz2/overlays/dev
kubectl kustomize .            # 에러 확인: ../bsae 경로 오타, patch 파일 이름 불일치

cat > kustomization.yaml <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: kz-dev
namePrefix: dev-
resources:
  - ../../base
patches:
  - path: replicas-patch.yaml
secretGenerator:
  - name: db-creds
    literals:
      - password=s3cr3t
    options:
      disableNameSuffixHash: true
EOF

kubectl kustomize .             # 경고/에러 없는지 확인, Secret 이름이 dev-db-creds 인지 확인
kubectl apply -k .
kubectl -n kz-dev get deploy,svc,secret
```

핵심:
- `bases:`는 `resources:`로, `patchesStrategicMerge:`는 `patches:`(path)로 바꾼다 (deprecated).
- 오타 난 경로(`../bsae`)와 실제 패치 파일 이름(`replicas-patch.yaml`)을 맞춘다.
- `namePrefix`가 있어도 kustomize가 secretKeyRef의 이름을 `dev-db-creds`로 자동 갱신한다. 해시 접미사는 `disableNameSuffixHash: true`로 끈다.

문서: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
