set -uo pipefail
source "$LIB/common.sh"
ns_create k8s rbac-dev
ns_create k8s rbac-prod
kapply k8s -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pipeline
  namespace: rbac-dev
  labels: {exam.q: "$QID"}
spec:
  replicas: 1
  selector:
    matchLabels: {app: pipeline}
  template:
    metadata:
      labels: {app: pipeline}
    spec:
      containers:
        - name: runner
          image: busybox:1.37
          command: ["sleep", "3600"]
YAML
term_sh 'mkdir -p /home/candidate/answers && rm -f /home/candidate/answers/q15-delete.txt'
