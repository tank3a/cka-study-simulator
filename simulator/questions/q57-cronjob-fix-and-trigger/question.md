Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The CronJob `report` in namespace `{{namespace}}` has never produced a Job. Fix it **in place** (do not delete it) so that:

1. it runs every 5 minutes (`*/5 * * * *`) and is not suspended
2. a new run is skipped while the previous one is still running (concurrency policy `Forbid`)
3. it keeps the last `2` successful and the last `1` failed Jobs
4. runs that cannot start within `60` seconds of their scheduled time are skipped (`startingDeadlineSeconds`)

Then start one run immediately from the CronJob, as a Job named `report-manual`, and make sure that Job completes.
