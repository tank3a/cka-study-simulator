set -uo pipefail
source "$LIB/common.sh"
term_sh 'mkdir -p /home/candidate/manifests; for f in tigera-operator.yaml custom-resources.yaml; do curl -fsS -o /home/candidate/manifests/$f http://exam-assets/manifests/$f || exit 1; done' || log "WARN: tigera-operator.yaml / custom-resources.yaml not available at http://exam-assets/manifests/ (stage them in exam-assets first)"
ns_create ik8s cni-b
kapply ik8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: net-probe, namespace: cni-b, labels: {exam.q: "$QID"}}
spec:
  replicas: 2
  selector: {matchLabels: {app: net-probe}}
  template:
    metadata: {labels: {app: net-probe}}
    spec:
      tolerations: [{key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}]
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector: {matchLabels: {app: net-probe}}
              topologyKey: kubernetes.io/hostname
      containers:
        - {name: web, image: "nginx:1.27"}
        - {name: cli, image: "busybox:1.37", command: ["sleep","3600"]}
YAML
