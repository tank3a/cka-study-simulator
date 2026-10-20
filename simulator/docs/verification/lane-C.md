# Lane C verification (q42 q44 q45 q47 q48 q49 q50 q51 q52 q109 q110)

Run on the shared live k8s cluster, solution scripts executed inside exam-term as `candidate`. Scores are points passed / total.

| id | setup ok | idempotent | untouched score | solution score | reset ok | fixes made | status | note |
|---|---|---|---|---|---|---|---|---|
| q42-pods-imagepull-crashloop | yes | yes | 0/8 | 8/8 | yes (0/8) | none | VERIFIED | |
| q44-service-selector-targetport | yes | yes | 1/8 | 8/8 | yes (1/8) | none | VERIFIED | untouched point is the shop-web endpoints check (valid: endpoints exist before the fix) |
| q45-netpol-ingress-chain | yes | yes | 0/9 | 9/9 | yes (0/9) | none | VERIFIED | |
| q47-netpol-egress-dns (ns egress-dns) | yes | yes | 0/7 | 7/7 | yes (0/7) | none | VERIFIED | |
| q48-service-readiness-nodeport | yes | yes | 0/8 | 8/8 | yes (0/8) | none | VERIFIED | curl to NodePort run from exam-term |
| q49-logs-events-crictl | yes | yes | 0/8 | 8/8 | yes (0/8) | solution.md: note that `logs --previous` can fail transiently right after a restart (`unable to retrieve container logs`), retry | VERIFIED | needed 1 retry-loop in my script; flaky window is kubelet/containerd, not the grader |
| q50-kubectl-top-usage | yes | yes | 0/7 | 7/7 | yes (0/7) | setup.sh: memhog `sh -c "x=...; sleep 36000"` exec'd sleep as the last command, freeing the 60MB variable, so memhog showed 0Mi and the memory check could never pass; added `; echo "${#x}"` after sleep so the shell stays resident (57Mi measured) | VERIFIED | depends on metrics-server scrape (~60-90s after setup) |
| q51-pvc-expand-two-classes | yes | yes | 0/6 | 6/6 | yes (0/6) | setup.sh: now removes stale /home/candidate/q51.txt | VERIFIED | |
| q52-rollback-to-named-revision | yes | yes | 0/8 | 8/8 | yes (0/8) | setup.sh: now removes stale /home/candidate/history-before.txt | VERIFIED | |
| q109-exec-multicontainer | yes | yes | 1/6 | 6/6 | yes (1/6) | none | VERIFIED | untouched point is the restartCount==0 check (acceptable) |
| q110-portforward-debug | yes | yes | 1/7 | 7/7 | yes (1/7) | solution.md: `kubectl debug` needs `--profile=general` (legacy profile has no SYS_PTRACE, so reading /proc/1/environ of the pause container's uid gives Permission denied); question.md: added a hint about `--profile` | VERIFIED | |

## Bug classes
- Solution text wrong: q110 (debug profile), q49 (transient --previous failure).
- Setup produced an unsolvable check: q50 (memhog memory never held).
- Stale candidate files could score on untouched state: q51, q52.
- Harness hazard (not a question bug): the candidate's ~/.kube/config current-context is shared by all lanes in exam-term. Concurrent `kubectl config use-context` calls from different lanes caused spurious "namespaces ... not found" during solution runs (seen in q49 and q110). Fix used: `cp ~/.kube/config /tmp/x; export KUBECONFIG=/tmp/x` at the top of each solution script.

Final state: all exam.q namespaces and StorageClasses (grow-sc, fixed-sc) of these questions removed; candidate home files and /opt/cka/q49-shipper-id.txt removed.
