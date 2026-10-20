#!/usr/bin/env bash
# Run ONCE while online. Populates simulator/assets-cache/{manifests,charts,apt}. Idempotent (skips existing files; --force to refetch).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; C="$ROOT/assets-cache"
FORCE=0; [ "${1:-}" = "--force" ] && FORCE=1
NGF=${NGF_VERSION:-2.8.0}; MS=${MS_VERSION:-v0.9.0}; CALICO=${CALICO_VERSION:-v3.33.0}; CM=${CM_VERSION:-v1.21.2}
mkdir -p "$C/manifests" "$C/charts" "$C/apt" "$C/docs-offline"
get() { local out=$1 url=$2; if [ ! -s "$C/$out" ] || [ $FORCE = 1 ]; then echo "fetch $out"; curl -fsSL "$url" -o "$C/$out.tmp" && mv "$C/$out.tmp" "$C/$out"; fi; }
get manifests/metrics-server.yaml "https://github.com/kubernetes-sigs/metrics-server/releases/download/$MS/components.yaml"
get manifests/calico.yaml        "https://raw.githubusercontent.com/projectcalico/calico/$CALICO/manifests/calico.yaml"
get manifests/calico-tigera-operator.yaml "https://raw.githubusercontent.com/projectcalico/calico/$CALICO/manifests/tigera-operator.yaml"
get manifests/calico-custom-resources.yaml "https://raw.githubusercontent.com/projectcalico/calico/$CALICO/manifests/custom-resources.yaml"
# names the q88/q89 setups fetch from http://exam-assets/manifests/ (tigera-operator.yaml, custom-resources.yaml)
for pair in "calico-tigera-operator.yaml:tigera-operator.yaml" "calico-custom-resources.yaml:custom-resources.yaml"; do
  src=${pair%%:*}; dst=${pair##*:}; [ -s "$C/manifests/$src" ] && { [ -s "$C/manifests/$dst" ] && [ $FORCE = 0 ] || cp "$C/manifests/$src" "$C/manifests/$dst"; }
done
get manifests/cert-manager.crds.yaml "https://github.com/cert-manager/cert-manager/releases/download/$CM/cert-manager.crds.yaml"
get manifests/ingress-nginx-kind.yaml "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.3/deploy/static/provider/kind/deploy.yaml" || true
if [ ! -s "$C/manifests/gateway-api-crds.yaml" ] || [ $FORCE = 1 ]; then
  echo "fetch gateway-api CRDs (version pinned by NGF $NGF)"
  kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v$NGF" > "$C/manifests/gateway-api-crds.yaml"
fi
if [ ! -s "$C/charts/nginx-gateway-fabric-$NGF.tgz" ]; then
  echo "pull NGF chart"; (cd "$C/charts" && helm pull oci://ghcr.io/nginx/charts/nginx-gateway-fabric --version "$NGF")
fi
# sample charts for helm tasks: public repos (online once) + a generated local chart
if [ ! -s "$C/charts/cert-manager-$CM.tgz" ]; then
  helm pull cert-manager --repo https://charts.jetstack.io --version "$CM" -d "$C/charts" || echo "WARN cert-manager chart not fetched"
fi
if [ ! -s "$C/charts/podinfo-6.7.1.tgz" ]; then
  helm pull podinfo --repo https://stefanprodan.github.io/podinfo --version 6.7.1 -d "$C/charts" || echo "WARN podinfo chart not fetched"
fi
if [ ! -d "$C/.gen/webapp" ]; then
  mkdir -p "$C/.gen"; (cd "$C/.gen" && helm create webapp >/dev/null)
  sed -i.bak 's/^version:.*/version: 0.1.0/; s/^appVersion:.*/appVersion: "1.27"/' "$C/.gen/webapp/Chart.yaml"; rm -f "$C/.gen/webapp/Chart.yaml.bak"
  helm package "$C/.gen/webapp" -d "$C/charts" >/dev/null
  sed -i.bak 's/^version:.*/version: 0.2.0/' "$C/.gen/webapp/Chart.yaml"; rm -f "$C/.gen/webapp/Chart.yaml.bak"
  helm package "$C/.gen/webapp" -d "$C/charts" >/dev/null
fi
helm repo index "$C/charts" --url http://exam-assets/charts
# k8s v1.35 debs for upgrade tasks (best effort; needs docker, builds a flat apt repo)
if [ "${WITH_APT:-0}" = 1 ] && [ ! -s "$C/apt/Packages.gz" ]; then
  docker run --rm -v "$C/apt:/out" debian:12-slim bash -c '
    set -e; apt-get update -qq; apt-get install -y -qq curl gpg dpkg-dev >/dev/null
    for p in kubeadm kubelet kubectl cri-tools kubernetes-cni; do :; done
    base=https://pkgs.k8s.io/core:/stable:/v1.35/deb
    curl -fsSL $base/Packages -o /tmp/Packages
    cd /out
    for p in kubeadm kubelet kubectl kubernetes-cni; do   # kubelet Depends: kubernetes-cni
      f=$(awk -v p=$p "/^Package: /{pk=\$2} /^Architecture: /{ar=\$2} /^Filename: /{if(pk==p && ar==\"arm64\")print \$2}" /tmp/Packages | tail -1); curl -fsSLO $base/$f; done
    dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz; dpkg-scanpackages . /dev/null > Packages'
fi
echo "assets ready in $C"
