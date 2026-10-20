# cka-sim/node: kind node + real sshd + sudo + vim + etcdctl/etcdutl
FROM alpine:3.20 AS etcd
ARG TARGETARCH
RUN apk add --no-cache curl tar && A=${TARGETARCH:-arm64} && \
    curl -fsSL https://github.com/etcd-io/etcd/releases/download/v3.6.4/etcd-v3.6.4-linux-$A.tar.gz | tar xz -C /tmp && \
    cp /tmp/etcd-v3.6.4-linux-$A/etcdctl /tmp/etcd-v3.6.4-linux-$A/etcdutl /usr/local/bin/
FROM kindest/node:v1.34.0
COPY --from=etcd /usr/local/bin/etcdctl /usr/local/bin/etcdutl /usr/local/bin/
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      openssh-server sudo vim less nano iputils-ping dnsutils netcat-openbsd procps ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -s /bin/bash -u 1000 candidate \
 && echo 'candidate ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/candidate && chmod 440 /etc/sudoers.d/candidate \
 && mkdir -p /home/candidate/.ssh /root/.ssh && chmod 700 /home/candidate/.ssh /root/.ssh \
 && printf 'PasswordAuthentication no\nPermitRootLogin prohibit-password\nUseDNS no\n' > /etc/ssh/sshd_config.d/10-cka.conf \
 && systemctl enable ssh \
 && echo "export KUBECONFIG=/etc/kubernetes/admin.conf" > /root/.bash_profile_kube \
 && echo '[ -f /root/.bash_profile_kube ] && . /root/.bash_profile_kube; alias k=kubectl; export EDITOR=vim; source <(kubectl completion bash); complete -F __start_kubectl k; export ETCDCTL_API=3' >> /root/.bashrc \
 && printf 'set ts=2 sw=2 expandtab\n' > /root/.vimrc \
 && mkdir -p /etc/containerd/certs.d/exam-assets:5000 \
 && printf 'server = "http://exam-assets:5000"\n[host."http://exam-assets:5000"]\n  capabilities = ["pull","resolve"]\n' > /etc/containerd/certs.d/exam-assets:5000/hosts.toml
COPY authorized_keys /tmp/authorized_keys
RUN install -o candidate -g candidate -m 600 /tmp/authorized_keys /home/candidate/.ssh/authorized_keys \
 && chown candidate:candidate /home/candidate/.ssh && install -m 600 /tmp/authorized_keys /root/.ssh/authorized_keys && rm /tmp/authorized_keys
RUN echo "deb [trusted=yes] http://exam-assets/apt ./" > /etc/apt/sources.list.d/cka.list
