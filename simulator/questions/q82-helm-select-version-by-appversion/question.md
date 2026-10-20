Context: `kubectl config use-context {{context}}`

The Helm repository at `http://exam-assets/charts` publishes the chart `cka-notes` in several versions. Namespace `{{namespace}}` exists.

1. Add the repository under the name `platform` and refresh the index.
2. The notes service must run **application version 1.4** (`APP VERSION`), which is **not** the newest chart. Find the chart version that carries it and write only the chart version (for example `1.2.3`) to `/home/candidate/answers/q82-version.txt`.
3. Save the default values of exactly that chart version to `/home/candidate/answers/q82-values.yaml`.
4. Install that chart version as release `notes` in namespace `{{namespace}}` with the replica count overridden to `2` on the command line. Wait until it is ready.

Constraints:
- It must be a Helm release (no `kubectl apply` of rendered manifests).
