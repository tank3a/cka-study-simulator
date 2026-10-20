set -uo pipefail
source "$LIB/common.sh"
ns_create k8s shop-back
ns_create k8s shop-front
ns_create k8s shop-other
kapply k8s -n shop-back -f - <<MANIFEST
apiVersion: apps/v1
kind: Deployment
metadata: {name: api}
spec:
  replicas: 1
  selector: {matchLabels: {app: api}}
  template:
    metadata: {labels: {app: api}}
    spec:
      containers:
      - {name: nginx, image: "nginx:1.27", ports: [{containerPort: 80}]}
---
apiVersion: v1
kind: Service
metadata: {name: api}
spec:
  selector: {app: api}
  ports: [{port: 80, targetPort: 80}]
MANIFEST
for spec in "shop-front web frontend" "shop-front batch batch" "shop-other intruder frontend"; do
  set -- $spec
  kapply k8s -n "$1" -f - <<MANIFEST
apiVersion: v1
kind: Pod
metadata: {name: $2, labels: {role: $3}}
spec:
  containers:
  - {name: bb, image: "busybox:1.37", command: ["sleep", "86400"]}
MANIFEST
done
wait_ready k8s deploy/api -n shop-back 120
wait_ready k8s pod/web -n shop-front 120
wait_ready k8s pod/batch -n shop-front 120
wait_ready k8s pod/intruder -n shop-other 120
# default-deny exists from the start; the candidate must not touch it
kapply k8s -n shop-back -f - <<MANIFEST
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny-ingress}
spec:
  podSelector: {}
  policyTypes: [Ingress]
MANIFEST
term_put /home/candidate/netpol/np-a.yaml <<MANIFEST
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-a
  namespace: shop-back
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 80
MANIFEST
term_put /home/candidate/netpol/np-b.yaml <<MANIFEST
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-b
  namespace: shop-back
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: shop-front
      podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
MANIFEST
term_put /home/candidate/netpol/np-c.yaml <<MANIFEST
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-c
  namespace: shop-back
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: shop-front
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
MANIFEST
exit 0
