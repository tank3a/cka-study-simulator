# Lane D verification (q54-q68)

Harness: setup x2, grade untouched, solution script run inside exam-term as candidate, grade, cleanup, setup+grade again, final cleanup (namespaces deleted; the shared VPA stand-in CRD kept).

| id | setup ok | idempotent | untouched score | solution score | reset ok | fixes made | status | note |
|---|---|---|---|---|---|---|---|---|
| q54 | yes | yes | 0/8 | 8/8 | yes | none | VERIFIED | |
| q55 | yes | yes | 1/7 | 7/7 | yes | none | VERIFIED | |
| q56 | yes | yes | 0/7 | 7/7 | yes | none | VERIFIED | solution leaves /home/candidate/job.yaml, job-out.txt in exam-term |
| q57 | yes | yes | 0/8 | 8/8 | yes | none | VERIFIED | |
| q58 | yes | yes | 1/6 | 6/6 | yes | none | VERIFIED | |
| q59 | yes | yes | 1/6 | 6/6 | yes | none | VERIFIED | |
| q60 | yes | yes | 0/10 | 10/10 | yes | none | VERIFIED | |
| q61 | yes (after fix) | yes | 0/7 | 7/7 | yes | q61/q62 setup: stand-in CRD in a protected group (`*.k8s.io`) was rejected (missing `api-approved.kubernetes.io` annotation), so no VPA CRD existed; added the annotation | VERIFIED | |
| q62 | yes (after fix) | yes | 0/9 | 9/9 | yes | same CRD annotation fix; also setup.sh gated both the Deployment and the VPA on the Deployment existing, so a failed VPA create was never retried; split into two gates | VERIFIED | |
| q63 | yes | yes | 1/9 | 9/9 | yes | none | VERIFIED | |
| q64 | yes | yes | 2/8 | 8/8 | yes | none | VERIFIED | untouched 2 pts are the "limits kept" style checks |
| q65 | yes | yes | 2/8 | 8/8 | yes | grade.sh: jsonpath `['requests.cpu']` bracket keys returned empty with kubectl; replaced by `.requests\.cpu` escape form (also in check_used) | VERIFIED | first solution run scored 3/8 because of this grader bug |
| q66 | yes | yes | 0/10 | 10/10 | yes | grade.sh: same jsonpath bracket-key bug for `count/deployments.apps`, `requests.storage`, `services.nodeports`; use `.count/deployments\.apps` etc. | VERIFIED | first solution run 6/10 |
| q67 | yes | yes | 0/8 | 8/8 | yes | none | VERIFIED | no node label/taint changes needed |
| q68 | yes | yes | 2/8 | 8/8 | yes | none | VERIFIED | no node label/taint changes needed (control-plane taint only read) |

Bug classes: (1) setup CRD for protected API group missing approval annotation; (2) setup idempotency gate covering two objects; (3) kubectl jsonpath bracket notation with dotted keys (ResourceQuota resource names) does not work, use backslash-escaped dots.
Side note: concurrent `kubectl config use-context` by several terminal sessions hit `~/.kube/config.lock` (harness artifact of running lanes in parallel, harmless).
