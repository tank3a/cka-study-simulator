set -uo pipefail
source "$LIB/assert.sh"
N=ek8s-cp
check_node_sh "script exists, is executable and takes \$1" 2 $N '[ -x /opt/cka/etcd-backup.sh ] && grep -q "snapshot save" /opt/cka/etcd-backup.sh && grep -Eq "\\\$\{?(1|\{1)" /opt/cka/etcd-backup.sh'
check_node_sh "script fails without an argument" 1 $N '[ -x /opt/cka/etcd-backup.sh ] && ! /opt/cka/etcd-backup.sh >/dev/null 2>&1'
check_node_sh "script works for another path" 2 $N '/opt/cka/etcd-backup.sh /tmp/grade-snap.db >/dev/null 2>&1; rc=1; etcdutl snapshot status /tmp/grade-snap.db >/dev/null 2>&1 && rc=0; rm -f /tmp/grade-snap.db; exit $rc'
check_node_sh "snapshot at the requested path is valid" 2 $N 'etcdutl snapshot status /opt/cka/backups/etcd-snap.db >/dev/null 2>&1'
check_file "status json has revision, hash, totalKey" 1 $N /opt/cka/etcd-snap-status.json '"revision".*"totalKey"|"totalKey".*"revision"|"hash"'
check_file "endpoint status table with leader column" 1 $N /opt/cka/etcd-endpoint-status.txt 'IS LEADER'
