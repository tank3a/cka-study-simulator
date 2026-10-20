# q82 풀이

```bash
kubectl config use-context k8s
helm repo add platform http://exam-assets/charts
helm repo update

# 모든 버전과 APP VERSION 확인
helm search repo platform/cka-notes --versions
#  platform/cka-notes  0.3.0  2.0  ...
#  platform/cka-notes  0.2.0  1.4  ...     <- app version 1.4
echo 0.2.0 > ~/answers/q82-version.txt

helm show values platform/cka-notes --version 0.2.0 > ~/answers/q82-values.yaml
helm install notes platform/cka-notes --version 0.2.0 -n helm-notes --set replicaCount=2 --wait
helm list -n helm-notes
```

함정: `--version`을 빼면 최신(0.3.0)이 설치된다. 검색은 `--versions`(또는 `-l`)를 써야 이전 버전이 나온다. CHART VERSION과 APP VERSION은 서로 다른 열이다.

문서: https://helm.sh/docs/intro/using_helm/
