You must use context `{{context}}` for this task:

    kubectl config use-context {{context}}

Namespace: `{{namespace}}`

The cluster has an IngressClass `public` that is currently the default class. The platform team now wants a second class that becomes the new default.

1. Create an IngressClass named `internal` handled by the controller `k8s.io/ingress-nginx`.
2. Make `internal` the **default** IngressClass of the cluster, and make sure `public` is no longer a default (do not delete `public`).
3. In namespace `ing-class` create an Ingress named `docs` **without** setting `ingressClassName`: host `docs.example.com`, path `/` (Prefix) -> Service `docs`, port 80. Afterwards the Ingress must have been assigned the class `internal` by the cluster.

The Service `docs` already exists.
