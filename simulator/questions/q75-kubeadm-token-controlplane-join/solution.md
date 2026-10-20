# q75 풀이

```bash
ssh ek8s-cp; sudo -i
# 1) 컨트롤 플레인 인증서를 클러스터에 업로드하고 certificate key 받기 (출력 마지막 줄이 key)
KEY=$(kubeadm init phase upload-certs --upload-certs | tail -1)
echo $KEY

# 2) 지정한 ID/TTL/설명으로 토큰을 만들면서 join 명령까지 출력 (CA hash 자동 포함)
kubeadm token create 0a1b2c.0123456789abcdef --ttl 45m --description "second control plane" \
  --print-join-command --certificate-key $KEY > /opt/cka/cp-join.txt
cat /opt/cka/cp-join.txt
# 예: kubeadm join <endpoint>:6443 --token 0a1b2c... --discovery-token-ca-cert-hash sha256:... --control-plane --certificate-key <key>
kubeadm token list
```

주의: 같은 ID의 토큰이 이미 있으면 create가 실패한다 (먼저 `kubeadm token list`). 토큰을 먼저 만들었다면 `kubeadm token delete`로 지우고 위 명령 한 번으로 다시 만든다.

핵심: 컨트롤 플레인 join에는 `--control-plane`과 `--certificate-key`가 추가로 필요하고, 인증서는 `kubeadm-certs` Secret에 2시간만 보관된다.

문서: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
      https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
