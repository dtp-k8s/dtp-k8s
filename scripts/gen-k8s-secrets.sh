#!/usr/bin/env bash
# Create Kubernetes secrets from .env files in configs/

set -euo pipefail

# cd to the root of the repository
cd "$(git rev-parse --show-toplevel)"

# Get the list of `*.env` files in the `k8s-env` directory
ENV_FILES=$(find k8s-env -name "*.env" -not -name "*.example.env")

# Generate Kubernetes secret manifests for each env file
mkdir -p k8s-secrets
for ENV_FILE in $ENV_FILES; do
    SECRET_NAME=$(basename "$ENV_FILE" .env)-config
    kubectl create secret generic \
        "$SECRET_NAME" \
        --from-env-file="$ENV_FILE" \
        --dry-run=client -o yaml > "k8s-secrets/$SECRET_NAME.yaml"
    echo "✅  Generated Kubernetes secret manifest for $SECRET_NAME at k8s-secrets/$SECRET_NAME.yaml"
done

# Apply the generated secrets to the cluster
kubectl apply -f k8s-secrets/
echo "✅  Applied all Kubernetes secrets to the cluster."
echo ""
