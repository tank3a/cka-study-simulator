# q71 풀이

```bash
kubectl config use-context k8s
K=~/kc/ravi.kubeconfig
# 현재 kubeconfig의 서버/CA 값을 그대로 사용 (--raw로 CA 데이터 확보)
SERVER=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')
kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > /tmp/ca.crt

kubectl config set-cluster kcfg-cluster --server="$SERVER" --certificate-authority=/tmp/ca.crt --embed-certs=true --kubeconfig=$K
kubectl config set-credentials ravi --client-certificate=$HOME/creds/ravi.crt --client-key=$HOME/creds/ravi.key --embed-certs=true --kubeconfig=$K
kubectl config set-context ravi@kcfg --cluster=kcfg-cluster --user=ravi --namespace=kcfg --kubeconfig=$K
kubectl config use-context ravi@kcfg --kubeconfig=$K

kubectl --kubeconfig=$K get pods          # 동작 확인
kubectl config get-contexts -o name | sort > ~/answers/q71-contexts.txt
```

함정: `--embed-certs=true`를 빼면 파일 경로만 저장되어 다른 곳에서 쓸 수 없다. `--minify`만 쓰면 CA 데이터가 가려지므로 `--raw`가 필요하다.

문서: https://kubernetes.io/docs/reference/kubectl/quick-reference/ (kubectl config 섹션)
