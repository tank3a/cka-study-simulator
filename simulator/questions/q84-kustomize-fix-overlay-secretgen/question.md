Context: `kubectl config use-context {{context}}`

`/home/candidate/kz2/base` contains a Deployment `web` and a Service `web`. The Deployment reads its password from the Secret `db-creds` (`secretKeyRef`). The overlay `/home/candidate/kz2/overlays/dev` was written by a colleague and does not build.

Fix it and deploy it to namespace `{{namespace}}` (it exists):

1. `kubectl kustomize /home/candidate/kz2/overlays/dev` must build without errors or deprecation warnings (replace the deprecated fields with their current equivalents).
2. The overlay must keep the name prefix `dev-`, the namespace `{{namespace}}`, and apply the existing replica patch file (it sets 3 replicas).
3. Add a `secretGenerator` that creates the Secret `db-creds` with the key `password` and the value `s3cr3t`, **without** the hash suffix in its name. The Deployment must end up referencing the generated (prefixed) Secret.
4. Apply the overlay with `kubectl`.

Constraints:
- Do not modify any file in `/home/candidate/kz2/base`.
- Do not create the Secret by hand with `kubectl create secret`.
