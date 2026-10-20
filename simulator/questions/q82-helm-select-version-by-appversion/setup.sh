set -uo pipefail
source "$LIB/common.sh"
mkchart() { # dir version appversion
  mkdir -p "$1/templates"
  printf 'apiVersion: v2\nname: cka-notes\nversion: %s\nappVersion: "%s"\ndescription: Notes service\n' "$2" "$3" > "$1/Chart.yaml"
  printf 'replicaCount: 1\nimage:\n  repository: nginx\n  tag: "1.27"\n' > "$1/values.yaml"
  cat > "$1/templates/deployment.yaml" <<'EOT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-notes
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}-notes
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-notes
    spec:
      containers:
        - name: notes
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
EOT
}
ns_create k8s helm-notes
# exam-assets serves $SIM_ROOT/assets-cache read-only at /srv (http://exam-assets/charts): publish into the host directory.
AC="$SIM_ROOT/assets-cache/charts"
if ! grep -q 'cka-notes' "$AC/index.yaml" 2>/dev/null || [ ! -s "$AC/cka-notes-0.2.0.tgz" ] || [ ! -s "$AC/cka-notes-0.3.0.tgz" ]; then
  log "cka-notes missing in the offline repo, publishing it into $AC"
  T=$(mktemp -d)
  mkchart "$T/c1" 0.2.0 1.4 && mkchart "$T/c2" 0.3.0 2.0
  helm package "$T/c1" -d "$AC" >/dev/null && helm package "$T/c2" -d "$AC" >/dev/null
  if [ -s "$AC/index.yaml" ]; then helm repo index "$AC" --url http://exam-assets/charts --merge "$AC/index.yaml"
  else helm repo index "$AC" --url http://exam-assets/charts; fi
  rm -rf "$T"
fi
term_sh 'mkdir -p /home/candidate/answers; rm -f /home/candidate/answers/q82-version.txt /home/candidate/answers/q82-values.yaml; helm repo remove platform >/dev/null 2>&1; true'
