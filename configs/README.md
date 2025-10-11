# Secret configuration files for the Kubernetes cluster

This directory contains configuration files used to generate Kubernetes [secrets](https://kubernetes.io/docs/concepts/configuration/secret/).  Secrets should be created in the `.env` format and are converted into Kubernetes secrets using `scripts/gen-k8s-secrets.sh`.  For example, the file `foo.env` with contents:

```properties
admin_password=dtp-super-secret-123
password=dtp-secret-123
```

results in the Kubernetes manifest:

```yaml
apiVersion: v1
data:
  admin_password: ZHRwLXN1cGVyLXNlY3JldC0xMjM=
  password: ZHRwLXNlY3JldC0xMjM=
kind: Secret
metadata:
  name: foo-config
```

!!!warning
    Secrets manifest files in Kubernetes are only base64-encoded, not encrypted.  Check your `.gitignore` to make sure these files are not committed!  You should also use `git status` to check the list of files being tracked by Git.

See the Kubernetes documentation for [handling secrets as either volumes or environment variables](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/).  Additionally, some Helm charts may ingest Kubernetes secrets by name, as configured using `values.yaml`.

## Getting started

Convert all `.example.env` files to `.env` files using:

```sh
find . -type f -name "*.example.env" -exec sh -c \
    'for f; do envfile="${f%.example.env}.env"; cp "$f" "$envfile"; done' sh {} +
```

Then, ensure that you have a running Kubernetes instance (`setup.sh` sets up [MicroK8s](https://microk8s.io/)).  Finally, run

```sh
cd $(git rev-parse --show-toplevel)  # repo root
./scripts/gen-k8s-secrets.sh
```

to generate and apply the Kubernetes manifests.
