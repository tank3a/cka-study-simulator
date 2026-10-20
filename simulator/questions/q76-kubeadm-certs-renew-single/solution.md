# q76 풀이

```bash
ssh ek8s-cp; sudo -i
# 1) CA 만료일
openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -enddate > /opt/cka/ca-notafter.txt

# 2) 인증서 하나만 갱신
kubeadm certs check-expiration | grep apiserver-kubelet-client
kubeadm certs renew apiserver-kubelet-client
kubeadm certs check-expiration | grep apiserver-kubelet-client     # 만료일 갱신 확인

# 3) static pod 재시작: 매니페스트를 잠깐 치웠다가 되돌린다 (kubelet이 Pod를 재생성)
mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/
until ! crictl ps | grep -q kube-apiserver; do sleep 3; done   # apiserver 컨테이너가 사라질 때까지
mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
crictl ps | grep kube-apiserver
kubectl get --raw=/readyz
```

함정: `kubeadm certs renew`는 파일만 교체하고 이미 떠 있는 컨트롤 플레인 프로세스는 새 인증서를 읽지 않으므로 반드시 재시작해야 한다. `renew all`은 다른 인증서도 바꾸므로 금지. 이 문제 후에는 ek8s를 cluster-soft reset 한다.

문서: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/
