set -uo pipefail
source "$LIB/assert.sh"
F=/home/candidate/answers/q26.txt
W=k8s-worker
SOCK=$(kc k8s get node $W -o jsonpath='{.metadata.annotations.kubeadm\.alpha\.kubernetes\.io/cri-socket}' 2>/dev/null)
CIDR=$(kc k8s get node $W -o jsonpath='{.spec.podCIDR}' 2>/dev/null)
CNIF=$(on_node $W ls /etc/cni/net.d 2>/dev/null | grep -v '\.bak$' | head -1)
SC=$(kc k8s get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{"\n"}{end}' 2>/dev/null | head -1)
PROV=$(kc k8s get sc "${SC:-standard}" -o jsonpath='{.provisioner}' 2>/dev/null)
check_file "cri_socket" 1 term $F "^cri_socket=${SOCK:-unix:///run/containerd/containerd.sock}\$"
check_file "runtime_name" 1 term $F '^runtime_name=containerd$'
check_file "cni_config_file" 1 term $F "^cni_config_file=${CNIF}\$"
check_file "cni_bin_dir" 1 term $F '^cni_bin_dir=/opt/cni/bin/?$'
check_file "pod_cidr" 1 term $F "^pod_cidr=${CIDR}\$"
check_file "default_storageclass" 1 term $F "^default_storageclass=${SC:-standard}\$"
check_file "csi_provisioner" 1 term $F "^csi_provisioner=${PROV:-rancher.io/local-path}\$"
check_jsonpath "RuntimeClass standard-runc handler" 1 k8s runtimeclass/standard-runc '{.handler}' runc
check_jsonpath "rc-pod uses the RuntimeClass" 1 k8s pod/rc-pod -n ext-if '{.spec.runtimeClassName}' standard-runc
check_eventually "rc-pod Running" 1 60 -- kc k8s -n ext-if wait --for=jsonpath='{.status.phase}'=Running pod/rc-pod --timeout=1s
