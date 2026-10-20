set -uo pipefail
source "$LIB/common.sh"
ns_create k8s kz-dev
term_sh 'rm -rf /home/candidate/kz2; mkdir -p /home/candidate/kz2/base /home/candidate/kz2/overlays/dev'
term_put /home/candidate/kz2/base/kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
YAML
term_put /home/candidate/kz2/base/deployment.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: nginx:1.27
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-creds
                  key: password
YAML
term_put /home/candidate/kz2/base/service.yaml <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
    - port: 80
YAML
term_put /home/candidate/kz2/overlays/dev/kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: kz-dev
namePrefix: dev-
bases:
  - ../bsae
patchesStrategicMerge:
  - patch-replicas.yaml
YAML
term_put /home/candidate/kz2/overlays/dev/replicas-patch.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
YAML
