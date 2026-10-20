# Lane G verification (ek8s: etcd / certs / control-plane faults)

Method: setup run directly (twice, idempotency), grade untouched, solution applied as candidate-equivalent ssh/sed script, grade again, `sim restore-node` (+`--etcd` for etcd) between destructive questions. Score = points passed / total.

| id | setup ok | untouched score | solution score | reset/restore ok | fixes made | status | note |
|---|---|---|---|---|---|---|---|
| q17 | yes (x2) | 2/7 before fix, 0/7 after | 7/7 | yes; /opt/cka/etcd-backup.db survives restore-node and restore-node --etcd | grade.sh: "snapshot is valid" passed with no file (etcdctl 3.6 has no `snapshot status`, prints help rc=0 so the `\|\|` fallback always passed); now `[ -s file ] && etcdutl snapshot status` | VERIFIED | |
| q20 | yes (x2) | 0/8 | 8/8 | yes | none | VERIFIED | |
| q21 | yes | 0/5 | 5/5 | yes | none (draft sol script needed `ssh -n` inside a piped script; not a question bug) | VERIFIED | |
| q75 | yes (x2) | 0/6 | 6/6 | yes | none | VERIFIED | `kubeadm token create ID --certificate-key K --print-join-command` works |
| q79 | yes (x2) | 1/9 before fix, 0/9 after | 9/9 | yes | grade.sh: "script fails without an argument" passed when the script did not exist; gated on `-x` | VERIFIED | |
| q76 | yes (x2) | 3/6 before fix, 0/6 after | 6/6 | yes (pki restored from baseline) | grade.sh: the three "unchanged/healthy" checks now require that apiserver-kubelet-client was renewed / ca-notafter.txt exists; solution.md: wait loop until the apiserver container is gone instead of fixed sleep 25 (old container was still running at 25s) | VERIFIED | |
| q37 | yes (x2) | 0/7 | 7/7 | yes | none | VERIFIED | NotReady appears ~40s after setup |
| q39 | yes (x2) | 1/8 before fix, 0/8 after | 8/8 | yes | grade.sh: "etcd-servers untouched" passed untouched; gated on a fault being fixed | VERIFIED | |
| q40 | yes (x2) | 1/8 before fix, 0/8 after | 8/8 | yes | setup.sh was NOT idempotent (`scheduler.conf` regex `.` matched `-`, second run produced `scheduler-conf.yaml.yaml`); anchored with `\.conf$`. grade.sh: "not pinned" gated on deployment available | VERIFIED | |
| q103 | yes (x2) | 1/9 before fix, 0/9 after | 9/9 | yes | setup.sh not idempotent (sa.key -> sa.key.old.old); anchored `sa.key$`. grade.sh: "manifest/mirror pod present" gated on cm-test Available | VERIFIED | |
| q104 | yes (x2) | 10/10 (!) before fix, 0/10 after | 10/10 | yes | BUG: the kubeadm baseline already contains `--controllers=*,bootstrapsigner,tokencleaner`, so `grep -q --controllers=` skipped the fault entirely and the question was unbroken. setup.sh now appends `,-replicaset,-job` to the existing flag (still inserts a new flag if none), waits for the restarted pod (match `-replicaset`) before creating workloads. Grader: 3 free checks gated on the flag being fixed / deploy available. solution.md updated (restore the default value; deleting the line also passes). | VERIFIED | solution run used `sed '/- --controllers=/d'`; restoring the default value is graded identically |
| q107 | yes (x2) | 1/8 before fix, 0/8 after | 8/8 | yes | setup.sh not idempotent (apiserver.key.bak.bak); anchored. grade.sh: "no cert files deleted" gated on authorization-mode fixed | VERIFIED | |
| q108 | yes (x2) | 1/8 before fix, 0/8 after | 8/8 | yes | grade.sh: "not pinned" gated on deployment Available. Confirmed intermediate state (typo fixed only) is 0/1 Ready with startup probe failures, as solution.md says | VERIFIED | startupProbe 24x10s; not a timing problem |
| q18 | yes (x2) | 0/8 | 8/8 | yes (restore-node --etcd) | solution.md: added note that apiserver watch cache stays stale after etcd-only restore (LIST still shows restore-drop, GET says NotFound); restarting the apiserver static pod fixes it | VERIFIED | etcdutl 3.6.4 restore + hostPath-only edit works; grade passes because grader uses GET |
| q80 | yes (x2) | 6/8 before fix, 0/8 after | 8/8 | yes (restore-node --etcd) | grade.sh: 6 checks passed untouched; all gated on /var/lib/etcd.old/member existing. solution.md: same stale apiserver cache note (solution script restarts apiserver) | VERIFIED | |

## Bug classes found
1. Free points in untouched state (constraint checks not gated on the candidate's change): q17, q76, q79, q39, q40, q103, q107, q108, q80, q104.
2. Setup not idempotent / regex too loose on re-run (`.` matches `-`, unanchored prefix match): q40, q103, q107.
3. Fault never injected because the baseline already has the flag: q104.
4. Tool-version assumption: etcdctl 3.6 has no `snapshot status` and exits 0 with help text: q17 (grep for the same pattern in other graders: none found in questions/*/grade.sh).
5. Solution docs missing a real-world step: stale apiserver watch cache after etcd restore (q18, q80); q76 fixed sleep.

## Ordering notes confirmed
- q17 snapshot at /opt/cka/etcd-backup.db is kept by `restore-node ek8s-cp --etcd` (restore only touches /etc/kubernetes, kubelet units and /var/lib/etcd).
- Leftover files remain in /opt/cka on ek8s-cp (outputs of q17/q20/q75/q76/q79, snapshots, pki-orig); harmless, re-created by setups.
- Shared scratchpad warning: other lanes overwrite files with the same name in the scratchpad dir (my g.sh was replaced once); use a private subdir.

Final state: `bin/sim doctor` shows ek8s apiserver ready, nodes Ready, sshd active on both nodes; test namespaces removed.
