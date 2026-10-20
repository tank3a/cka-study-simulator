# q20 풀이

```bash
kubectl config use-context ek8s
ssh ek8s-cp; sudo -i
mkdir -p /opt/cka
kubeadm certs check-expiration > /opt/cka/cert-expiry.txt

kubeadm token create --ttl 2h --description "cka worker join" --print-join-command > /opt/cka/join-command.txt
kubeadm token list                       # 확인
kubeadm token delete abcdef.0123456789abcdef

openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -ext subjectAltName > /opt/cka/apiserver-sans.txt
# (구버전 openssl: openssl x509 -in ... -noout -text | grep -A1 'Subject Alternative Name')
```

핵심: `--print-join-command`가 token + `--discovery-token-ca-cert-hash`까지 출력. `check-expiration`은 읽기 전용이며 `renew`는 하지 않는다.

문서: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/
      https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
