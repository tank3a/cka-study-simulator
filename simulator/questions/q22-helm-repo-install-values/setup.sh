set -uo pipefail
source "$LIB/common.sh"
# Make sure the offline repo contains chart cka-web 1.0.0 and 1.1.0. exam-assets serves $SIM_ROOT/assets-cache read-only
# at /srv (http://exam-assets/charts), so publish into the host directory and re-index it.
AC="$SIM_ROOT/assets-cache/charts"
if ! grep -q 'cka-web-1.1.0.tgz' "$AC/index.yaml" 2>/dev/null || [ ! -s "$AC/cka-web-1.0.0.tgz" ]; then
  log "publishing cka-web 1.0.0/1.1.0 into $AC"
  helm package "$QDIR/chart" -d "$AC" >/dev/null && helm package "$QDIR/chart-1.1.0" -d "$AC" >/dev/null
  if [ -s "$AC/index.yaml" ]; then helm repo index "$AC" --url http://exam-assets/charts --merge "$AC/index.yaml"
  else helm repo index "$AC" --url http://exam-assets/charts; fi
fi
term_sh 'mkdir -p /home/candidate/helm /home/candidate/answers; rm -f /home/candidate/answers/q22-versions.txt; helm repo remove cka-charts >/dev/null 2>&1; true'
term_put /home/candidate/helm/web-values.yaml <<'YAML'
replicaCount: 1
service:
  type: NodePort
  nodePort: 30082
message: "hello from cka"
YAML
