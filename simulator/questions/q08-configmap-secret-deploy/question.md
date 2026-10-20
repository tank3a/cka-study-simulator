Context: `kubectl config use-context {{context}}`   Namespace: `{{namespace}}`

The Deployment `api` in namespace `{{namespace}}` currently runs without configuration. A properties file is
available at `/home/candidate/app.properties`.

1. Create a ConfigMap `api-config` with:
   - the literal key `LOG_LEVEL` with value `debug`
   - the key `app.properties` whose content is the file `/home/candidate/app.properties`
2. Create a Secret `api-secret` (type Opaque) with `username=admin` and `password=S3cr3tPass`.
3. Modify the Deployment `api` so that its container:
   - gets an environment variable `LOG_LEVEL` from the ConfigMap key `LOG_LEVEL`
   - gets an environment variable `DB_PASSWORD` from the Secret key `password`
   - sees the ConfigMap file at `/etc/api/app.properties` (mount the ConfigMap as a volume at `/etc/api`)
   - sees the Secret mounted as files in `/etc/secrets`, read-only, with file mode `0400`

The Pods of `api` must be Running with the new configuration. Keep the Deployment name and image unchanged.
