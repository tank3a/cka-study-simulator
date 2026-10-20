Context: `kubectl config use-context {{context}}`
Host: `{{host}}` (use `sudo -i` on the node)

Security asks you to rotate the certificate that the API server uses to talk to the kubelets.

1. With `openssl`, write the expiry line (`notAfter=...`) of the cluster CA `/etc/kubernetes/pki/ca.crt` to `/opt/cka/ca-notafter.txt`.
2. Renew **only** the kubeadm certificate `apiserver-kubelet-client` (the files under `/etc/kubernetes/pki`).
3. Make the kube-apiserver use the renewed certificate by restarting its static Pod. The API must be healthy again at the end.

Constraints:
- Do not renew any other certificate (do not use `renew all`).
- Do not edit the content of the kube-apiserver manifest and do not delete or modify the CA.
