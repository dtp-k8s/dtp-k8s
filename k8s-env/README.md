# .env files for setting up Kubernetes secrets

This directory contains `.env` files for generating Kubernetes secrets.

## Setup

To initialize this folder, we need to generate a set of `.env` files from the corresponding `.example.env` files.  Run:

```sh
find . -type f -name "*.example.env" -exec sh -c \
    'for f; do envfile="${f%.example.env}.env"; cp --update=none "$f" "$envfile"; done' sh {} +
```

The use of `--update=none` ensures that existing `.env` files are not overwritten.

## Translation and installation

The script `scripts/gen-k8s-secrets.sh`:

1. Generates a Kubernetes Secret manifest (YAML file) for each `.env` file in `k8s-env/` (excluding `.example.env` files)
2. Installs the contents of `k8s-env/` into the Kubernetes cluster.
