Context: `kubectl config use-context {{context}}`

A backup operator vendor installed several CustomResourceDefinitions. The group of the backup API is `ops.cka.example.com`.

1. Write the names of all CRDs of group `ops.cka.example.com` (full CRD names such as `xyz.group`), one per line, sorted, to `/home/candidate/answers/q25-crds.txt`. CRDs of other groups must not be listed.
2. Use `kubectl explain` to document the field `spec.retentionDays` of the `Backup` resource and save the output to `/home/candidate/answers/q25-explain.txt`.
3. Create a `Backup` object named `nightly` in namespace `{{namespace}}` with:
   - `spec.schedule`: `0 2 * * *`
   - `spec.target`: `pvc/data`
   - `spec.retentionDays`: `14`
4. Write the total number of `Backup` objects in **all namespaces** (after you created `nightly`) as a single number to `/home/candidate/answers/q25-count.txt`.

Constraints:
- The object must pass the schema validation of the CRD: read the CRD to learn the valid value range and required fields.
- Do not edit or delete any CRD.
