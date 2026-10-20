**Context:** `kubectl config use-context {{context}}`

Namespace `{{namespace}}` contains two Pods that are not exposed outside the cluster (create `/home/candidate/q110/` if needed):

1. Pods `report-v1` and `report-v2` serve HTTP on port 80 and answer `GET /version`. The Service `report` only selects `report-v1`.
   Use `kubectl port-forward` directly to Pod `report-v2` (local port `18080`), request `/version` and write the response body to `/home/candidate/q110/v2-version.txt`.
2. Pod `sealed` runs an image with no shell and no tools. Attach an **ephemeral debug container** with image `busybox:1.37` that targets container `app`,
   and use it to read the environment variable `LICENSE_TIER` of the `app` container's main process. Write only the value to `/home/candidate/q110/license.txt`.
   (Hint: the default debug profile may lack the privileges to read another user's process data; see `kubectl debug --help` for `--profile`.)

Constraints:
- Do not delete, recreate or edit the Pods `report-v1`, `report-v2` or `sealed` (no `--copy-to`), and do not change the Service.
- The port-forward must run in the background or in a second terminal; stop it when you are done.
