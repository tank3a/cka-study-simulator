# Lane F verification (q69 q70 q71 q73 q74 q77 q81 q82 q83 q84 q85 q86 q87 q90)

Run 2026-10-18 on the live clusters. Scores are passed/total points. Procedure: setup twice, grade untouched, solution.md run as `candidate` in exam-term (node steps via ssh), grade, cleanup + setup + grade (reset), final cleanup. Notes on the "untouched" column: the untouched score listed is the value after the gating fixes below (the pre-fix value is in the fixes column).

| id | setup ok | idempotent | untouched score | solution score | reset ok | fixes made | status | note |
|---|---|---|---|---|---|---|---|---|
| q69-clusterrole-group-nonresource | yes | yes | 0/11 (was 3/11) | 11/11 | yes (0/11) | grade.sh: 3 negative checks (outside-group cannot list, cr-b denied, other cannot get /metrics), "no wildcard" check: all gated on the positive grant being present | VERIFIED | |
| q70-csr-user-certificate | yes | yes | 0/10 (was 2/10) | 10/10 | yes | grade.sh: "cert matches key" passed with both files missing (md5 of empty output), "no access in default" passed untouched: both gated | VERIFIED | |
| q71-kubeconfig-build-user | yes | yes | 0/11 (was 2/11) | 11/11 | yes | grade.sh: "no external file paths" and "default kubeconfig untouched" passed with no file: gated on the file existing | VERIFIED | |
| q73-kubeadm-init-config-file | yes | yes | 0/9 | 9/9 | yes | none | VERIFIED | kubeadm 1.34 validates v1beta4 file; image list OK |
| q74-kubeadm-config-fix-migrate | yes | yes | 0/8 | 8/8 | yes | solution.md: `kubeadm config migrate` DROPS the KubeletConfiguration document (verified), so the solution now appends it explicitly; migrate also auto-prefixes `unix://` on criSocket | VERIFIED | |
| q77-kubeadm-upgrade-plan-runbook | yes | yes | 0/6 (was 1/6) | 6/6 | yes | grade.sh: "worker still schedulable" gated on drain-dryrun.txt existing | VERIFIED | `kubeadm upgrade plan` works read-only (falls back to stable-1.34 with a warning); server dry-run drain left the worker schedulable |
| q81-ha-external-etcd-config | yes | yes | 0/9 | 9/9 | yes | none | VERIFIED | lease holder is `ek8s-control-plane_<uuid>`; cut -d_ -f1 correct |
| q82-helm-select-version-by-appversion | yes | yes | 0/7 | 7/7 | yes | setup.sh: chart publishing used `docker cp` into the read-only /charts mount (and a `docker exec test -d /charts`); now packages into host `$SIM_ROOT/assets-cache/charts` and re-indexes with `--merge` (same as q22). grade.sh: "release deployed" check always failed with rc=141 (SIGPIPE: `helm status \| grep -q` under pipefail); output now captured first | VERIFIED | cka-notes 0.2.0 (app 1.4) and 0.3.0 (app 2.0) now in assets-cache/charts and the index (left published, harmless) |
| q83-helm-history-rollback-revision | yes | yes | 0/7 (was 1/7) | 7/7 | yes | grade.sh: "pods Running" passed untouched (old RS still available): gated on the last revision being a rollback | VERIFIED | |
| q84-kustomize-fix-overlay-secretgen | yes | yes | 0/9 (was 1/9) | 9/9 | yes (after deleting ns kz-dev, as the default reset does; no cleanup.sh) | grade.sh: "base untouched" passed untouched: gated on the overlay building | VERIFIED | confirmed `bases`/`patchesStrategicMerge` emit deprecation warnings, solution removes them |
| q85-crd-versions-schema-facts | yes | yes | 0/11 (was 1/11) | 11/11 | yes | grade.sh: "CRD untouched" passed untouched: gated on w5 existing | VERIFIED | no cleanup.sh: the default reset removes the labelled CRD and namespaces |
| q86-crd-author-database | yes | yes | 0/11 | 11/11 | yes | grade.sh: the two "rejected" checks passed when the CRD did not exist (apply fails for any reason): gated on a valid object being accepted | VERIFIED | |
| q87-operator-install-rbac-leader | yes | yes | 0/11 (was 2/11) | 11/11 | yes | grade.sh: "cannot delete/create" and "least privilege" passed with no RBAC: both gated on the ClusterRole/Role existing | VERIFIED | |
| q90-csi-driver-storageclass-objects | yes | yes | 0/11 (was 1/11) | 11/11 | yes | grade.sh: "csi-fast is not default" passed when the SC did not exist: gated | VERIFIED | PVC stays Pending, CSINode count 0, default provisioner rancher.io/local-path, as documented |

## Bug classes found
1. Negative checks that pass on untouched state (q69, q70, q71, q77, q83, q84, q85, q86, q87, q90): fixed by gating on the candidate's change.
2. Pipefail/SIGPIPE in `producer | grep -q` inside check_sh (q82); worth grepping the rest of the bank for `helm status ... | grep -q` / long producers before `grep -q`.
3. Offline chart publishing into the read-only assets mount (q82), same as the earlier q22 fix.
4. Solution text wrong about tool behaviour (q74: `kubeadm config migrate` drops the KubeletConfiguration doc).

## Final state
All lane F namespaces, ClusterRoles/Bindings, CSR dana/ravi-kcfg, CRDs (widgets, databases, syncjobs), StorageClass csi-fast, CSIDriver, helm releases, node files under /opt/cka (q73/q74/q77/q81) and candidate home files (csr, creds, kc, crd, kz2, operator, answers q71/q81-q87/q90) removed. Only addition left behind: cka-notes charts in assets-cache/charts (needed by q82).
