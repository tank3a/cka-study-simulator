set -uo pipefail
source "$LIB/common.sh"
ns_create k8s helm-ledger
H="helm --kubeconfig $ADMIN_KUBECONFIG --kube-context k8s"
T=$(mktemp -d)
mkdir -p "$T/ledger/templates"
printf 'apiVersion: v2\nname: ledger\nversion: 0.1.0\nappVersion: "1.0"\n' > "$T/ledger/Chart.yaml"
printf 'replicaCount: 1\nimage:\n  repository: nginx\n  tag: "1.26"\n' > "$T/ledger/values.yaml"
cat > "$T/ledger/templates/deployment.yaml" <<'EOT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
EOT
if ! $H -n helm-ledger status ledger >/dev/null 2>&1; then
  $H -n helm-ledger install ledger "$T/ledger" --set image.tag=1.26 --wait --timeout 90s
  $H -n helm-ledger upgrade ledger "$T/ledger" --set image.tag=1.27-alpine --wait --timeout 90s
  $H -n helm-ledger upgrade ledger "$T/ledger" --set image.tag=1.99.99-nope --set replicaCount=2
fi
rm -rf "$T"
term_sh 'mkdir -p /home/candidate/answers; rm -f /home/candidate/answers/q83-revision.txt /home/candidate/answers/q83-values.yaml'
