#!/usr/bin/env bash

set -euo pipefail

# Set current directory to the script's location
cd "$(dirname "$0")"

# We obtain this chart from the Bitnami Helm repo, add it if not already present
if ! helm repo list -o yaml | yq '.[].name' | grep -q '^bitnami$'; then
    echo "🚚  Adding Bitnami Helm repo..."
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    echo "✅  Added Bitnami Helm repo."
fi
echo ""

echo "🚚  Installing PostgreSQL via Helm..."
if helm list -A --short | grep -q '^postgres$'; then
    if gum confirm "⚠️  PostgreSQL Helm release already exists. Upgrade?" ; then
        echo "🛠️  Upgrading PostgreSQL via Helm..."
        helm upgrade --install postgres bitnami/postgresql --namespace default -f values.yaml --wait
        echo "✅  Upgraded PostgreSQL."
    else
        echo "⏭️  Skipping PostgreSQL installation."
    fi
else
    # Install PostgreSQL via Helm
    echo "🛠️  Installing PostgreSQL via Helm..."
    helm upgrade --install postgres bitnami/postgresql --namespace default -f values.yaml --wait
    echo "✅  Installed PostgreSQL."
fi
echo ""
