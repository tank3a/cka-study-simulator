# q74 풀이

```bash
ssh ek8s-cp; sudo -i
cd /opt/cka
# 1) 구버전 설정을 최신 API 버전으로 변환 (원본은 건드리지 않음)
kubeadm config migrate --old-config broken-init.yaml --new-config fixed-init.yaml
head -50 fixed-init.yaml      # 주의: migrate는 KubeletConfiguration 문서를 버린다(검증됨). 아래처럼 직접 추가
printf -- '---\napiVersion: kubelet.config.k8s.io/v1beta1\nkind: KubeletConfiguration\ncgroupDriver: systemd\n' >> fixed-init.yaml

# 2~4) 값 수정
vim fixed-init.yaml
#   criSocket: unix:///run/containerd/containerd.sock
#   podSubnet: 10.244.0.0/16
#   (KubeletConfiguration은 위에서 cgroupDriver: systemd로 추가함)

# 5) 검증
kubeadm config validate --config fixed-init.yaml
diff broken-init.yaml fixed-init.yaml
```

함정: Pod CIDR 10.96.0.0/16은 Service CIDR 10.96.0.0/12에 포함되어 겹친다. `migrate`는 값을 고쳐주지 않고 API 버전만 변환한다. kubelet의 cgroupDriver는 컨테이너 런타임 설정과 같아야 한다.

문서: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
