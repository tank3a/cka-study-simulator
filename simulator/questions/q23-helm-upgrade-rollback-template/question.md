Context: `kubectl config use-context {{context}}`

Release `shop` (chart directory `/home/candidate/helm/cka-app`) runs in namespace `{{namespace}}`. The last upgrade broke it (Pods cannot pull their image).

1. Inspect the release history of `shop` and roll back to the last revision that worked.
2. Then upgrade `shop` with the chart in `/home/candidate/helm/cka-app` so that it runs **3 replicas**. Keep every value the release already has (do not reset values to the chart defaults) and do not change the image.
3. Without installing anything, render the chart as release name `preview` for namespace `{{namespace}}` with the values file `/home/candidate/helm/preview-values.yaml` and save the resulting manifests to `/home/candidate/answers/preview.yaml`.

Constraints:
- All three Pods of `shop` must be Running at the end.
- Rendering (step 3) must not create a release or any cluster object.
- Do not delete and re-install `shop`.
