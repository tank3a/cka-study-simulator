set -uo pipefail
source "$LIB/common.sh"
ns_create k8s kz-prod
term_sh 'rm -rf /home/candidate/kustomize; mkdir -p /home/candidate/kustomize/base /home/candidate/kustomize/overlays/prod'
term_put /home/candidate/kustomize/base/kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
YAML
term_put /home/candidate/kustomize/base/deployment.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api
          image: nginx:1.26
          envFrom:
            - configMapRef:
                name: api-config
          resources:
            limits:
              cpu: 200m
              memory: 64Mi
YAML
term_put /home/candidate/kustomize/base/service.yaml <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  selector:
    app: api
  ports:
    - port: 80
      targetPort: 80
YAML
