# Images
Nodes have internet access; images are pulled on demand (nothing is preloaded: `kind load` is unreliable with Docker's containerd image store).
Safe, small choices: `busybox:1.37`, `nginx:1.27`, `registry.k8s.io/pause:3.10`, `httpd:2.4`. Calico images pull from docker.io. The exam-term has NO internet (only the kind network).
A local registry is at `exam-assets:5000` (plain http; node containerd is configured for it; push from the Mac via `localhost:5055`).
