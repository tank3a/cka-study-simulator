Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

Create a Job named `batch-calc` in namespace `{{namespace}}`:

- image `busybox:1.37`, container name `calc`, command `sh -c 'echo done-$HOSTNAME'`
- must complete `6` times, with at most `2` Pods running in parallel
- Pods are never restarted in place on failure (`restartPolicy: Never`), at most `3` retries (`backoffLimit`)
- the whole Job must be terminated if it runs longer than `120` seconds
- the finished Job (and its Pods) must be removed automatically `600` seconds after it finishes

When the Job has finished, save the log of **one** of its Pods into `/home/candidate/job-out.txt` on the terminal host.
