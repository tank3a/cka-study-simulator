# q22 풀이

```bash
kubectl config use-context k8s
helm repo add cka-charts http://exam-assets/charts
helm repo update
helm search repo cka-charts/cka-web --versions > ~/answers/q22-versions.txt

helm install web cka-charts/cka-web --version 1.0.0 \
  -n helm-web --create-namespace \
  -f ~/helm/web-values.yaml --set replicaCount=3 --wait

helm list -n helm-web
helm get values web -n helm-web
kubectl -n helm-web get deploy,svc
```

핵심: `-f`와 `--set`이 같은 키를 정의하면 `--set`이 우선. `--version`을 생략하면 최신(1.1.0)이 설치되므로 주의. `--create-namespace`로 네임스페이스 생성. 값 이름이 기억나지 않으면 `helm show values cka-charts/cka-web --version 1.0.0`.

문서: https://helm.sh/docs/intro/using_helm/
