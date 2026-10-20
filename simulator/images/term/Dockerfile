# cka-sim/term: the exam terminal
FROM alpine:3.20 AS tools
ARG TARGETARCH
RUN apk add --no-cache curl tar && A=${TARGETARCH:-arm64} && cd /tmp && \
    curl -fsSLo kubectl https://dl.k8s.io/release/v1.34.1/bin/linux/$A/kubectl && \
    curl -fsSL https://get.helm.sh/helm-v3.18.6-linux-$A.tar.gz | tar xz && \
    curl -fsSLo yq https://github.com/mikefarah/yq/releases/download/v4.47.1/yq_linux_$A && \
    curl -fsSL https://github.com/etcd-io/etcd/releases/download/v3.6.4/etcd-v3.6.4-linux-$A.tar.gz | tar xz && \
    curl -fsSL https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.34.0/crictl-v1.34.0-linux-$A.tar.gz | tar xz && \
    install -m755 kubectl yq crictl /usr/local/bin/ && install -m755 linux-$A/helm /usr/local/bin/helm && \
    install -m755 etcd-v3.6.4-linux-$A/etcdctl etcd-v3.6.4-linux-$A/etcdutl /usr/local/bin/

FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash bash-completion vim nano tmux less jq curl wget openssl openssh-client iputils-ping dnsutils \
      netcat-openbsd tree man-db ca-certificates iptables iproute2 gosu procps git coreutils python3 \
 && rm -rf /var/lib/apt/lists/* \
 && (userdel -r ubuntu 2>/dev/null || true) && useradd -m -s /bin/bash -u 1000 candidate
COPY --from=tools /usr/local/bin/ /usr/local/bin/
COPY bashrc /etc/skel/.cka_bashrc
COPY tmux.conf /home/candidate/.tmux.conf
COPY entrypoint.sh /entrypoint.sh
RUN cat /etc/skel/.cka_bashrc >> /home/candidate/.bashrc \
 && printf 'set ts=2 sw=2 expandtab\n' > /home/candidate/.vimrc \
 && mkdir -p /home/candidate/.ssh /home/candidate/.kube /var/lib/exam && chmod 700 /home/candidate/.ssh \
 && chown -R candidate:candidate /home/candidate /var/lib/exam && chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sleep","infinity"]
