set -uo pipefail
source "$LIB/common.sh"
ns_create k8s widget-lab
ns_create k8s widget-other
kapply k8s -f - <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.shop.cka.example.com
  labels: {exam.q: "$QID"}
spec:
  group: shop.cka.example.com
  scope: Namespaced
  names: {plural: widgets, singular: widget, kind: Widget, shortNames: [wg], categories: [shop]}
  versions:
    - name: v1alpha1
      served: true
      storage: false
      deprecated: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                color: {type: string}
                size: {type: string}
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required: [size]
              properties:
                color: {type: string, enum: [red, green, blue]}
                size: {type: string, enum: [S, M, L]}
YAML
kc k8s wait --for condition=established crd/widgets.shop.cka.example.com --timeout=30s >/dev/null
kapply k8s -f - <<YAML
apiVersion: shop.cka.example.com/v1
kind: Widget
metadata: {name: w1, namespace: widget-lab}
spec: {color: red, size: M}
---
apiVersion: shop.cka.example.com/v1
kind: Widget
metadata: {name: w2, namespace: widget-lab}
spec: {color: blue, size: S}
---
apiVersion: shop.cka.example.com/v1
kind: Widget
metadata: {name: w3, namespace: widget-lab}
spec: {color: red, size: L}
---
apiVersion: shop.cka.example.com/v1
kind: Widget
metadata: {name: w4, namespace: widget-other}
spec: {color: red, size: S}
YAML
kc k8s -n widget-lab delete widget w5 w6 --ignore-not-found >/dev/null 2>&1
term_sh 'mkdir -p /home/candidate/crd /home/candidate/answers; rm -f /home/candidate/answers/q85.txt'
term_put /home/candidate/crd/widget-broken.yaml <<'YAML'
apiVersion: shop.cka.example.com/v1
kind: Widget
metadata:
  name: w6
  namespace: widget-lab
spec:
  colour: green
  size: XL
YAML
