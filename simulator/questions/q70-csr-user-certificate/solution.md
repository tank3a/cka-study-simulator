# q70 풀이

```bash
kubectl config use-context k8s
cd ~/csr
openssl genrsa -out dana.key 2048
openssl req -new -key dana.key -subj "/CN=dana/O=devs" -out dana.csr

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: dana
spec:
  request: $(base64 -w0 dana.csr)
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages:
  - client auth
EOF

kubectl certificate approve dana
kubectl get csr dana -o jsonpath='{.status.certificate}' | base64 -d > dana.crt
openssl x509 -in dana.crt -noout -subject -dates      # 확인

kubectl -n csr-lab create rolebinding dana-view --clusterrole=view --user=dana
kubectl -n csr-lab auth can-i get pods --as=dana
```

함정: `request`는 PEM을 base64(개행 없이)로 넣는다. `expirationSeconds`는 최소 600초. 인증서의 O(organization)는 그룹 이름이 된다.

문서: https://kubernetes.io/docs/reference/access-authn-authz/rbac/ (CSR 전용 페이지는 official.md 목록에 없음; kubectl certificate approve 도움말은 `kubectl certificate --help`)
