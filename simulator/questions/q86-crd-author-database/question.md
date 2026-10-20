Context: `kubectl config use-context {{context}}`

Create a CustomResourceDefinition from scratch. Save the manifest as `/home/candidate/crd/database-crd.yaml` and apply it.

- API group `data.cka.example.com`, kind `Database`, plural `databases`, singular `database`, short name `db`, scope **Namespaced**.
- One version `v1` (served and stored).
- Schema for `spec`:
  - `engine` (string, **required**, allowed values `postgres` and `mysql` only);
  - `replicas` (integer, minimum `1`, maximum `5`, default `1`).
- The `status` subresource must be enabled.
- `kubectl get databases` must show an extra column `Engine` with the value of `spec.engine`.

Then create the Database `orders` in namespace `{{namespace}}` with engine `postgres` and 3 replicas.

Constraints:
- Do not use `x-kubernetes-preserve-unknown-fields`; the schema must reject invalid objects.
