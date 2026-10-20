Context: `kubectl config use-context {{context}}`

The directory `/home/candidate/kustomize/base` contains a Deployment `api` and a Service `api`. The directory `/home/candidate/kustomize/overlays/prod` exists but is empty.

Create `/home/candidate/kustomize/overlays/prod/kustomization.yaml` so that building it produces the production variant, then deploy it to the cluster:

- Namespace `{{namespace}}` for all resources (the namespace already exists).
- Name prefix `prod-` for all resources.
- Label `env: prod` on all resources.
- Deployment replicas: `3`.
- Container image `nginx` with tag `1.27-alpine`.
- A ConfigMap generated with `configMapGenerator` named `api-config` containing `LOG_LEVEL=warn`. The Deployment already references a ConfigMap named `api-config` via `envFrom`: make sure it points to the generated one.
- A patch that sets the memory limit of the container `api` to `128Mi`.
- Apply the result with `kubectl`.

Constraints:
- Do not modify any file in `/home/candidate/kustomize/base`.
- Do not create the production objects with `kubectl create` or hand-written copies of the manifests.
