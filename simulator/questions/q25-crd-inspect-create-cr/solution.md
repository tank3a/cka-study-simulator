# q25 풀이

```bash
kubectl config use-context k8s
mkdir -p ~/answers
kubectl get crd -o name | sed 's#.*/##' | grep '\.ops\.cka\.example\.com$' | sort > ~/answers/q25-crds.txt
# 또는: kubectl get crd | grep ops.cka.example.com   (group이 정확히 일치하는지 확인: help.cka... 제외)

kubectl api-resources --api-group=ops.cka.example.com      # kind/short name 확인
kubectl explain backup.spec.retentionDays > ~/answers/q25-explain.txt

kubectl get crd backups.ops.cka.example.com -o yaml | less  # required: schedule,target / retentionDays 1~30
cat <<'YAML' | kubectl apply -f -
apiVersion: ops.cka.example.com/v1
kind: Backup
metadata:
  name: nightly
  namespace: crd-demo
spec:
  schedule: "0 2 * * *"
  target: pvc/data
  retentionDays: 14
YAML

kubectl get backups -A --no-headers | wc -l > ~/answers/q25-count.txt
```

핵심: `kubectl explain`은 CRD의 openAPIV3Schema를 읽는다(`kubectl explain backup.spec` 도 가능). 범위를 벗어난 값(예: 99)은 서버가 거부한다. 실제 operator는 이런 CR을 보고 reconcile 하는 컨트롤러(Deployment)이다.

문서: https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/
      https://kubernetes.io/docs/concepts/extend-kubernetes/operator/
