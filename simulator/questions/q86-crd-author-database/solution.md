# q86 풀이

```bash
kubectl config use-context k8s
cat > ~/crd/database-crd.yaml <<'EOF'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.data.cka.example.com      # <plural>.<group> 이어야 한다
spec:
  group: data.cka.example.com
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
    shortNames: [db]
  versions:
  - name: v1
    served: true
    storage: true
    subresources:
      status: {}
    additionalPrinterColumns:
    - name: Engine
      type: string
      jsonPath: .spec.engine
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: [engine]
            properties:
              engine:
                type: string
                enum: [postgres, mysql]
              replicas:
                type: integer
                minimum: 1
                maximum: 5
                default: 1
EOF
kubectl apply -f ~/crd/database-crd.yaml
kubectl wait --for=condition=established crd/databases.data.cka.example.com

cat <<'EOF' | kubectl apply -f -
apiVersion: data.cka.example.com/v1
kind: Database
metadata: {name: orders, namespace: crd-author}
spec: {engine: postgres, replicas: 3}
EOF
kubectl -n crd-author get db
```

함정: CRD의 `metadata.name`은 `<plural>.<group>`과 정확히 같아야 하고, `apiextensions.k8s.io/v1`에서는 `schema`가 필수다. `required`는 `spec` 객체 안에 둔다. `default`는 서버가 채워 주며, `kubectl apply --dry-run=server`로 검증할 수 있다.

문서: https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/
