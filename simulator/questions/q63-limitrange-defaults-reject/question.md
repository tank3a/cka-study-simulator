Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

1. In namespace `{{namespace}}` create a LimitRange `cpu-mem-limits` for containers (type `Container`) with:
   - default limits: `cpu: 500m`, `memory: 256Mi`
   - default requests: `cpu: 100m`, `memory: 128Mi`
   - maximum: `cpu: 1`, `memory: 512Mi`
   - minimum: `cpu: 50m`, `memory: 64Mi`
2. Create the Pod from `/home/candidate/lr-plain.yaml` (it declares no resources) in namespace `{{namespace}}`.
3. Create the Pod from `/home/candidate/lr-toobig.yaml` in namespace `{{namespace}}`. It must be rejected by the cluster; do not edit the file.
   Save the error message printed by `kubectl` into `/home/candidate/lr-error.txt`.
