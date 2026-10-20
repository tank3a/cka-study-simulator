Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The StatefulSet `web` (3 replicas, image `nginx:1.27`, headless Service `web`) in namespace `{{namespace}}` serves a stateful app.
Roll out the new image `nginx:1.27-alpine` as a **canary**:

1. Configure the update strategy so that only the Pod with ordinal `2` (`web-2`) is updated to the new image; `web-0` and `web-1` must keep `nginx:1.27`
   and must not be restarted.
2. Change the PVC retention policy so that the PVCs are **kept** when the StatefulSet is deleted but **deleted** when the StatefulSet is scaled down.
3. Do not delete the StatefulSet or any PVC.
