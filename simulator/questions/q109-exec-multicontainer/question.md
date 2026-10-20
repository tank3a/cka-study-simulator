**Context:** `kubectl config use-context {{context}}`

Pod `orders` in namespace `{{namespace}}` has two containers: `app` (nginx) and `audit` (busybox). Use `kubectl exec` (create `/home/candidate/q109/` if needed):

1. Print the value of the environment variable `APP_REGION` **inside the `app` container** and write only the value to `/home/candidate/q109/region.txt`.
2. Count the lines containing `DENIED` in `/var/log/audit/audit.log` **inside the `audit` container** and write only the number to `/home/candidate/q109/denied-count.txt`.
3. From the `audit` container (which has `wget`, not `curl`) request `http://127.0.0.1/` (the nginx in the other container, same Pod network) and write the content of the HTML `<title>` element (text only) to `/home/candidate/q109/title.txt`.
4. Create the empty file `/tmp/inspected` inside the `app` container.

Constraints:
- Do not restart, recreate or edit the Pod; do not change any Deployment or ConfigMap.
- The Pod has no default container annotation: always name the container with `-c`.
