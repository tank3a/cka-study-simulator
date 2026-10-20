Context: `kubectl config use-context {{context}}`

The platform team publishes charts in a Helm repository at `http://exam-assets/charts`.

1. Add the repository with the name `cka-charts` and update the repository index.
2. Save the output of the search that lists **all available versions** of the chart `cka-web` to `/home/candidate/answers/q22-versions.txt`.
3. Install chart `cka-web` as release `web` in namespace `{{namespace}}` (create the namespace as part of the installation).
   - Use chart version `1.0.0` (not the latest one).
   - Use the values file `/home/candidate/helm/web-values.yaml`.
   - Override the replica count to `3` on the command line (do not edit the values file).
4. Wait until all replicas are available.

Constraints:
- Do not render and `kubectl apply` the chart: it has to be a Helm release.
- Do not edit the values file.
